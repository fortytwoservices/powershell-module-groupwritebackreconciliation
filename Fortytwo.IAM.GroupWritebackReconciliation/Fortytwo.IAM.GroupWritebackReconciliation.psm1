# Inspiration: https://github.com/RamblingCookieMonster/PSStackExchange/blob/master/PSStackExchange/PSStackExchange.psm1

New-Variable -Scope Script -Name AccessTokenProfile -Value "default"
New-Variable -Scope Script -Name ADGroupFilter -Value $null
New-Variable -Scope Script -Name PreviousGroup -Value $null

# Get public and private function definition files.
$Private = (Test-Path $PSScriptRoot\Private) ? @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue ) : @()
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Exclude "*.tests.*" )

# Dot source the files in order to define all cmdlets
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Export all functions
Export-ModuleMember -Function $Public.Basename