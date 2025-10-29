function Get-GroupWritebackReconciliationOperations {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $false)]
        [Switch] $DoNotWarnIfMissingOnPremDN,

        [Parameter(Mandatory = $false)]
        [Switch] $DisableCacheForADGroupObjectSIDLookup
    )

    Process {
        Write-Verbose "Building cache of all AD groups by ObjectSID."
        $AllADGroups = @{}
        Get-ADGroup -Filter * | Foreach-object {
            $AllADGroups[$_.ObjectSID.ToString()] = $_
        }

        $ADGroups = Get-ADGroup -Filter $Script:ADGroupFilter -Properties member, adminDescription
        
        $ADGroupsByAdminDescription = @{}
        $ADGroups | ForEach-Object {
            if (
                $_.adminDescription -notmatch "^TakenOver_Group_[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$" -and    
                $_.adminDescription -notmatch "^Group_[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
            ) {
                Write-Warning "Group '$($_.Name)' does not have a valid adminDescription. Skipping group."
                continue
            }

            $ADGroupsByAdminDescription[($_.adminDescription -replace "^TakenOver_Group_" -replace "^Group_")] = $_
        }

        if (!$ADGroupsByAdminDescription) {
            Write-Error "No valid on-premises AD groups matching the filter."
            return @()
        }
        
        $ADGroupsByAdminDescription.GetEnumerator() | ForEach-Object {
            $ADGroup = $_.Value
            $EntraIDGroupObjectId = $_.Key

            Write-Verbose "Processing group '$($ADGroup.Name)' with objectguid '$($ADGroup.ObjectGUID)'."
            
            Write-Verbose " - Fetching Entra ID group members for group '$EntraIDGroupObjectId'."
            $EntraIDMembers = @{}
            $uri = "https://graph.microsoft.com/v1.0/groups/$EntraIDGroupObjectId/members?`$select=id,onPremisesDistinguishedName,onPremisesDomainName,onPremisesSamAccountName,onPremisesSecurityIdentifier&`$top=999"
            
            try {
                do {
                    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers (Get-EntraIDAccessTokenHeader -Profile $Script:AccessTokenProfile)
                    if ($Response.value) {
                        foreach ($Member in $Response.value) {
                            Write-Debug "Processing member with ID '$($Member.id)' of type '$($Member.'@odata.type')' in group '$EntraIDGroupObjectId'."
                            if($Member.'@odata.type' -eq "#microsoft.graph.user") {
                                if ($Member.onPremisesDistinguishedName) {
                                    $EntraIDMembers[$Member.onPremisesDistinguishedName] = $Member
                                }
                                else {
                                    if (!$DoNotWarnIfMissingOnPremDN.IsPresent) {
                                        Write-Warning "Member with ID '$($Member.id)' in group '$EntraIDGroupObjectId' does not have an onPremisesDistinguishedName. Skipping member."
                                    }
                                }
                            } elseif($Member.'@odata.type' -eq "#microsoft.graph.group") {
                                $Handled = $false
                                if(![string]::IsNullOrEmpty($Member.onPremisesSecurityIdentifier)) {
                                    if($AllADGroups.ContainsKey($Member.onPremisesSecurityIdentifier)) {
                                        Write-Debug "Resolved on-premises group member with ID '$($Member.id)' in group '$EntraIDGroupObjectId' via onPremisesSecurityIdentifier."
                                        $Handled = $true
                                        $EntraIDMembers[$AllADGroups[$Member.onPremisesSecurityIdentifier].DistinguishedName] = $Member
                                    }
                                }

                                if(!$Handled) {
                                    if($ADGroupsByAdminDescription.ContainsKey($Member.Id)) {
                                        Write-Debug "Resolved on-premises group member with ID '$($Member.id)' in group '$EntraIDGroupObjectId' via adminDescription."
                                        $Handled = $true
                                        $EntraIDMembers[$ADGroupsByAdminDescription[$Member.Id].DistinguishedName] = $Member
                                    }
                                }

                                if(!$Handled) {
                                    Write-Warning "Member with ID '$($Member.id)' in group '$EntraIDGroupObjectId' is an on-premises group that we are unable to handle. Skipping member."
                                }
                            } else {
                                Write-Warning "Member with ID '$($Member.id)' in group '$EntraIDGroupObjectId' is of unsupported type '$($Member.'@odata.type')'."
                            }
                        }
                    }
                    $Uri = $Response.'@odata.nextLink'
                } while ($Uri)

                Write-Verbose " - Found $($EntraIDMembers.Count) members in Entra ID group '$EntraIDGroupObjectId'."
            }
            catch {
                Write-Warning "Failed to fetch members for Entra ID group '$EntraIDGroupObjectId'. Error details: $($_.Exception.Message)"
                return
            }

            # Compare members
            $ADGroupMemberMap = @{}
            if($ADGroup.member) {
                $ADGroupMemberMap = $ADGroup.member | Group-Object -AsHashTable -AsString
            }

            # Find members in Entra that are not in AD
            if($EntraIDMembers) {
                $EntraIDMembers.Keys | 
                Where-Object { -not $ADGroupMemberMap.ContainsKey($_) } |
                ForEach-Object {
                    New-GroupWritebackReconciliationOperation -Action "Add member" -Group $ADGroup.DistinguishedName -Member $_
                }
            } else {
                Write-Warning "No members found in Entra ID group '$EntraIDGroupObjectId'."
            }

            # Find members in AD that are not in Entra (and should be removed)
            if ($ADGroupMemberMap) {
                $ADGroupMemberMap.Keys |
                Where-Object { -not $EntraIDMembers.ContainsKey($_) } |
                ForEach-Object {
                    New-GroupWritebackReconciliationOperation -Action "Remove member" -Group $ADGroup.DistinguishedName -Member $_
                }
            }
        }
    }
}