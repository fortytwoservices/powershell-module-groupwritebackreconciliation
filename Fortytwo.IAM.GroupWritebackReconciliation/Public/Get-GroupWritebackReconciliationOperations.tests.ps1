BeforeAll {
    Install-Module EntraIDAccessToken -Force -Scope CurrentUser
    Add-EntraIDExternalAccessTokenProfile -AccessToken "dummy"
    $Script:Module = Import-Module "$PSScriptRoot/../" -Force -PassThru -Global 

    # Mocking Active Directory module
    $MockupModule = New-Module -ScriptBlock {
        function Get-ADGroup {}
    }
    $MockupModule | Import-Module -Global
}

Describe "Get-GroupWritebackReconciliationOperations" -Tag Mocked {
    BeforeAll {
        Connect-GroupWritebackReconciliation -SkipAllTests

        # Mocking dependencies
        Mock -ModuleName $Script:Module.Name -CommandName Get-ADGroup -MockWith {
            return @(
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 1"
                    DistinguishedName = "CN=Group 1,DC=example,DC=com"
                    Name              = "Group 1"
                    Member            = @(
                        "CN=John M. Doe,OU=Users,DC=example,DC=com",
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = "takenover_bbbbbbbb-cccc-dddd-eeee-ffffffffffff"
                    ObjectGUID        = "1404be73-01c6-4801-9fce-4ad11a7284a3"
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 2"
                    DistinguishedName = "CN=Group 2,DC=example,DC=com"
                    Name              = "Group 2"
                    Member            = @(
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = "takenover_aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
                    ObjectGUID        = "bce7f444-fc13-4755-b877-608cf5e635a2"
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 3"
                    DistinguishedName = "CN=Group 3,DC=example,DC=com"
                    Name              = "Group 3"
                    Member            = @()
                    AdminDescription  = "takenover_cccccccc-dddd-eeee-ffff-000000000000"
                    ObjectGUID        = "d4f5e6a7-b8c9-40d1-92e3-4567890abcde"
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 4"
                    DistinguishedName = "CN=Group 4,DC=example,DC=com"
                    Name              = "Group 4"
                    Member            = @(
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = "takenover_dddddddd-eeee-ffff-0000-111111111111"
                    ObjectGUID        = "e5f6a7b8-c9d0-41e2-93f4-567890abcdef"
                }
            )
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/bbbbbbbb-cccc-dddd-eeee-ffffffffffff/members*" } -MockWith {
            Write-Warning "Mocked Invoke-RestMethod called with URI: $($Uri)"
            return @{value = @(
                    [PSCustomObject]@{ 
                        id                          = "38327624-a675-414d-ab8d-a4e25205cc8f"
                        onPremisesDistinguishedName = "CN=John M. Doe,OU=Users,DC=example,DC=com"
                    }
                )
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/members*" } -MockWith {
            Write-Warning "Mocked Invoke-RestMethod called with URI: $($Uri)"
            return @{value = @(
                    [PSCustomObject]@{ 
                        id                          = "38327624-a675-414d-ab8d-a4e25205cc8f"
                        onPremisesDistinguishedName = "CN=John M. Doe,OU=Users,DC=example,DC=com"
                    }
                )
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/cccccccc-dddd-eeee-ffff-000000000000/members*" } -MockWith {
            Write-Warning "Mocked Invoke-RestMethod called with URI: $($Uri)"
            return @{value = @(
                    [PSCustomObject]@{ 
                        id                          = "38327624-a675-414d-ab8d-a4e25205cc8f"
                        onPremisesDistinguishedName = "CN=John M. Doe,OU=Users,DC=example,DC=com"
                    }

                    [PSCustomObject]@{ 
                        id                          = "20085065-4f45-4547-a7c8-2050e3b03b90"
                        onPremisesDistinguishedName = "CN=John Smith,OU=Users,DC=example,DC=com"
                    }
                )
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/dddddddd-eeee-ffff-0000-111111111111/members*" } -MockWith {
            Write-Warning "Mocked Invoke-RestMethod called with URI: $($Uri)"
            throw [Microsoft.PowerShell.Commands.HttpResponseException]::new("Not found", [System.Net.Http.HttpResponseMessage]::new(404))
        }

        $Operations = Get-GroupWritebackReconciliationOperations -Verbose -Debug -ErrorAction Continue
        # $Operations | ConvertTo-Json | Write-Host -ForegroundColor Yellow
    }

    It "Should have a planned operation to add John M. Doe to Group 2" {
        $Operation = $Operations | Where-Object Action -eq "Add member" | Where-Object Group -eq "CN=Group 2,DC=example,DC=com"
        $Operation.Member | Should -Be "CN=John M. Doe,OU=Users,DC=example,DC=com"
    }
    
    It "Should have a planned operation to remove John Smith from Group 1" {
        $Operation = $Operations | Where-Object Action -eq "Remove member" | Where-Object Group -eq "CN=Group 1,DC=example,DC=com"
        $Operation.Member | Should -Be "CN=John Smith,OU=Users,DC=example,DC=com"
    }

    It "Should have a planned operation to remove John Smith from Group 2" {
        $Operation = $Operations | Where-Object Action -eq "Remove member" | Where-Object Group -eq "CN=Group 2,DC=example,DC=com"
        $Operation.Member | Should -Be "CN=John Smith,OU=Users,DC=example,DC=com"
    }

    It "Should have a planned operation to add two members to Group 3" {
        $Operation = $Operations | Where-Object Action -eq "Add member" | Where-Object Group -eq "CN=Group 3,DC=example,DC=com"
        $Operation.Member | Sort-Object | Should -Be @(
            "CN=John M. Doe,OU=Users,DC=example,DC=com",
            "CN=John Smith,OU=Users,DC=example,DC=com"
        )
    }

    It "Should be no operations for Group 4" {
        $Operation = $Operations | Where-Object Group -eq "CN=Group 4,DC=example,DC=com"
        $Operation | Should -Be $null
    }

    It "Should have a total of 5 planned operations" {
        $Operations.Count | Should -Be 5
    }
}