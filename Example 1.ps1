[CmdletBinding()]
Param()

Import-Module EntraIDAccessToken -Force
Import-Module Fortytwo.IAM.GroupWritebackConsolidation -Force

# Create an access token profile
$cs ??= Read-Host -AsSecureString -Prompt "Client secret for 55ffa0ca-c74f-4344-bf0e-af56ff30f920"
Add-EntraIDClientSecretAccessTokenProfile `
    -TenantId "237098ae-0798-4cf9-a3a5-208374d2dcfd" `
    -ClientId "55ffa0ca-c74f-4344-bf0e-af56ff30f920" `
    -ClientSecret $cs

# Connect the module
Connect-GroupWritebackConsolidation
    
$Operations = Get-GroupWritebackConsolidationOperations -Verbose
$Operations | Show-GroupWritebackConsolidationOperation

if ($Operations.Count -eq 0) {
    Write-Host -ForegroundColor Yellow "No operations to perform."
    return
}

Read-Host "Press Enter to continue..."

$Operations | Complete-GroupWritebackConsolidation -Verbose