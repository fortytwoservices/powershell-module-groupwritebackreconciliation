<#
.DESCRIPTION
    Connects the Connect-GroupWritebackReconciliation module to Entra ID and Active Directory.

.SYNOPSIS
    Connects the Connect-GroupWritebackReconciliation module to Entra ID and Active Directory.

.EXAMPLE
    Install-Module Fortytwo.IAM.GroupWritebackReconciliation -Scope CurrentUser

    Add-EntraIDClientSecretAccessTokenProfile `
        -TenantId "bb73082a-b74c-4d39-aec0-41c77d6f4850" `
        -ClientId "78f07963-ce55-4b23-b56a-2e13f2036d7f"

    Connect-GroupWritebackReconciliation
#>
function Connect-GroupWritebackReconciliation {
    [CmdletBinding()]

    Param(
        # Access token profile to use for authentication. the EntraIDAccessToken module must be installed and imported.
        [Parameter(Mandatory = $false)]
        [string]$AccessTokenProfile = "default",

        # Skips all tests when connecting. Use with caution.
        [Parameter(Mandatory = $false)]
        [Switch] $SkipAllTests,

        [Parameter(Mandatory = $false)]
        [ScriptBlock] $ADGroupFilter = { adminDescription -like "TakenOver_Group_*" }
    )

    Process {
        $Script:AccessTokenProfile = $AccessTokenProfile
        
        if ($SkipAllTests.IsPresent) {
            Write-Warning "⚠️ Skipping all connection tests. Proceed with caution!"
            return
        }

        if (!(Get-EntraIDAccessToken | Get-EntraIDAccessTokenHasRoles -Roles "groupmember.read.all", "groupmember.readwrite.all", "group.read.all", "group.readwrite.all" -Any)) {
            Write-Warning "⚠️ The access token profile '$AccessTokenProfile' does not have any of the required roles of: 'groupmember.read.all', 'groupmember.readwrite.all', 'group.read.all', 'group.readwrite.all'. Please ensure the profile is correct and has the necessary permissions."
        }
        else {
            Write-Verbose "✅ The access token profile '$AccessTokenProfile' has the required role for reading groups."
        }

        try {
            $ADGroups = Get-ADGroup -Filter $ADGroupFilter
            $Count = $ADGroups | Measure-Object | Select-Object -ExpandProperty Count
            if (!$ADGroups) {
                Write-Warning "⚠️ No on-premises AD groups matching the filter."
            }
            else {
                Write-Verbose "✅ Found $Count on-premises AD groups to process."
            }
        }
        catch {
            Write-Warning "⚠️ Failed to query on-premises AD groups. Please ensure you have the ActiveDirectory module installed and are connected to an on-premises AD environment.`nError details: $($_.Exception.Message)"
        }

        $Script:ADGroupFilter = $ADGroupFilter
    }
}