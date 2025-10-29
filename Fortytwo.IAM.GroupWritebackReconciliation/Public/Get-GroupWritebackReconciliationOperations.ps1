function Get-GroupWritebackReconciliationOperations {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $false)]
        [Switch] $DoNotWarnIfMissingOnPremDN
    )

    Process {
        $ADGroups = Get-ADGroup -Filter $Script:ADGroupFilter -Properties member, adminDescription

        if (!$ADGroups) {
            Write-Error "No on-premises AD groups matching the filter."
            return @()
        }
        
        foreach ($ADGroup in $ADGroups) {
            Write-Verbose "Processing group '$($ADGroup.Name)' with objectguid '$($ADGroup.ObjectGUID)'."
            
            if (
                $ADGroup.adminDescription -notmatch "^TakenOver_Group_[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$" -and    
                $ADGroup.adminDescription -notmatch "^Group_[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
            ) {
                Write-Warning "Group '$($ADGroup.Name)' does not have a valid adminDescription. Skipping group."
                continue
            }

            $EntraIDGroupObjectId = $ADGroup.adminDescription -replace "^TakenOver_Group_" -replace "^Group_"

            Write-Verbose " - Fetching Entra ID group members for group '$EntraIDGroupObjectId'."
            $EntraIDMembers = @{}
            $uri = "https://graph.microsoft.com/v1.0/groups/$EntraIDGroupObjectId/members?`$select=id,onPremisesDistinguishedName&`$top=999"
            
            try {
                do {
                    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers (Get-EntraIDAccessTokenHeader -Profile $Script:AccessTokenProfile)
                    if ($Response.value) {
                        foreach ($Member in $Response.value) {
                            if ($Member.onPremisesDistinguishedName) {
                                $EntraIDMembers[$Member.onPremisesDistinguishedName] = $Member
                            }
                            else {
                                if (!$DoNotWarnIfMissingOnPremDN.IsPresent) {
                                    Write-Warning "Member with ID '$($Member.id)' in group '$EntraIDGroupObjectId' does not have an onPremisesDistinguishedName. Skipping member."
                                }
                            }                        
                        }
                    }
                    $Uri = $Response.'@odata.nextLink'
                } while ($Uri)

                Write-Verbose " - Found $($EntraIDMembers.Count) members in Entra ID group '$EntraIDGroupObjectId'."
            }
            catch {
                Write-Error "Failed to fetch members for Entra ID group '$EntraIDGroupObjectId'. Error details: $($_.Exception.Message)"
                continue
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