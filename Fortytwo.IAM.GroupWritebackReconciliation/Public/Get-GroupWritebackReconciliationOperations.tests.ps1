BeforeAll {
    Install-Module EntraIDAccessToken -Force -Scope CurrentUser
    Add-EntraIDExternalAccessTokenProfile -AccessToken "dummy" -WarningAction SilentlyContinue
    $Script:Module = Import-Module "$PSScriptRoot/../" -Force -PassThru -Global 

    # Mocking Active Directory module
    $MockupModule = New-Module -ScriptBlock {
        function Get-ADGroup {}
    }
    $MockupModule | Import-Module -Global
}

AfterAll {
    Remove-Module -Name $Script:Module.Name -Force -ErrorAction SilentlyContinue
}

Describe "Get-GroupWritebackReconciliationOperations" -Tag Mocked {
    BeforeAll {
        Connect-GroupWritebackReconciliation -SkipAllTests -WarningAction SilentlyContinue

        # Mocking dependencies
        Mock -ModuleName $Script:Module.Name -CommandName Get-ADGroup -MockWith {
            param($Filter, $Properties)

            $_Groups = @(
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 1"
                    DistinguishedName = "CN=Group 1,DC=example,DC=com"
                    Name              = "Group 1"
                    Member            = @(
                        "CN=John M. Doe,OU=Users,DC=example,DC=com",
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = "TakenOver_Group_bbbbbbbb-cccc-dddd-eeee-ffffffffffff"
                    ObjectGUID        = "1404be73-01c6-4801-9fce-4ad11a7284a3"
                    ObjectSID         = @{value="S-1-5-21-1004336348-1177238915-682003330-512"}
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 2"
                    DistinguishedName = "CN=Group 2,DC=example,DC=com"
                    Name              = "Group 2"
                    Member            = @(
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = "TakenOver_Group_aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
                    ObjectGUID        = "bce7f444-fc13-4755-b877-608cf5e635a2"
                    ObjectSID         = @{value="S-1-5-21-1004336348-1177238915-682003330-513"}
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 3"
                    DistinguishedName = "CN=Group 3,DC=example,DC=com"
                    Name              = "Group 3"
                    Member            = @()
                    AdminDescription  = "TakenOver_Group_cccccccc-dddd-eeee-ffff-000000000000"
                    ObjectGUID        = "d4f5e6a7-b8c9-40d1-92e3-4567890abcde"
                    ObjectSID         = @{value="S-1-5-21-1004336348-1177238915-682003330-514"}
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 4"
                    DistinguishedName = "CN=Group 4,DC=example,DC=com"
                    Name              = "Group 4"
                    Member            = @(
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = "Group_dddddddd-eeee-ffff-0000-111111111111"
                    ObjectGUID        = "e5f6a7b8-c9d0-41e2-93f4-567890abcdef"
                    ObjectSID         = @{value="S-1-5-21-1004336348-1177238915-682003330-515"}
                }
                
                [PSCustomObject]@{ 
                    SamAccountName    = "Group 5"
                    DistinguishedName = "CN=Group 5,DC=example,DC=com"
                    Name              = "Group 5"
                    Member            = @(
                        "CN=John Smith,OU=Users,DC=example,DC=com"
                    )
                    AdminDescription  = $null
                    ObjectGUID        = "c474c2d2-32fe-4e67-8842-343fd99c0954"
                    ObjectSID         = @{value="S-1-5-21-1004336348-1177238915-682003330-516"}
                }
            )
        
            if ($Filter -eq "*") {
                return $_Groups
            } else {
                return $_Groups | Where-Object adminDescription -like "*Group*"
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/bbbbbbbb-cccc-dddd-eeee-ffffffffffff/members*" } -MockWith {
            Write-Debug "Mocked Invoke-RestMethod called with URI: $($Uri)"
            return @{value = @(
                    [PSCustomObject]@{ 
                        '@odata.type'               = "#microsoft.graph.user"
                        id                          = "38327624-a675-414d-ab8d-a4e25205cc8f"
                        onPremisesDistinguishedName = "CN=John M. Doe,OU=Users,DC=example,DC=com"
                    }

                    [PSCustomObject]@{ 
                        '@odata.type'               = "#microsoft.graph.group"
                        id                          = "fb7a1dda-2704-47ec-9456-2581780f3d08"
                        onPremisesSecurityIdentifier = "S-1-5-21-1004336348-1177238915-682003330-516"
                    }

                    [PSCustomObject]@{ 
                        '@odata.type'               = "#microsoft.graph.group"
                        id                          = "dddddddd-eeee-ffff-0000-111111111111"
                    }
                )
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/members*" } -MockWith {
            Write-Debug "Mocked Invoke-RestMethod called with URI: $($Uri)"
            return @{value = @(
                    [PSCustomObject]@{ 
                        '@odata.type'               = "#microsoft.graph.user"
                        id                          = "38327624-a675-414d-ab8d-a4e25205cc8f"
                        onPremisesDistinguishedName = "CN=John M. Doe,OU=Users,DC=example,DC=com"
                    }
                )
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/cccccccc-dddd-eeee-ffff-000000000000/members*" } -MockWith {
            Write-Debug "Mocked Invoke-RestMethod called with URI: $($Uri)"
            return @{value = @(
                    [PSCustomObject]@{ 
                        '@odata.type'               = "#microsoft.graph.user"
                        id                          = "38327624-a675-414d-ab8d-a4e25205cc8f"
                        onPremisesDistinguishedName = "CN=John M. Doe,OU=Users,DC=example,DC=com"
                    }

                    [PSCustomObject]@{ 
                        '@odata.type'               = "#microsoft.graph.user"
                        id                          = "20085065-4f45-4547-a7c8-2050e3b03b90"
                        onPremisesDistinguishedName = "CN=John Smith,OU=Users,DC=example,DC=com"
                    }
                )
            }
        }

        Mock -ModuleName $Script:Module.Name -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://graph.microsoft.com/*/groups/dddddddd-eeee-ffff-0000-111111111111/members*" } -MockWith {
            Write-Debug "Mocked Invoke-RestMethod called with URI: $($Uri)"
            throw [Microsoft.PowerShell.Commands.HttpResponseException]::new("Not found", [System.Net.Http.HttpResponseMessage]::new(404))
        }

        $Operations = Get-GroupWritebackReconciliationOperations -ErrorAction Continue
        # $Operations | ConvertTo-Json | Write-Host -ForegroundColor Yellow
    }

    It "Should have a planned operation to add John M. Doe to Group 2" {
        $Operation = $Operations | Where-Object Action -eq "Add member" | Where-Object Group -eq "CN=Group 2,DC=example,DC=com"
        $Operation.Member | Should -Be "CN=John M. Doe,OU=Users,DC=example,DC=com"
    }

    It "Should have a planned operation to add Group 5 to Group 1" {
        $Operation = $Operations | Where-Object Action -eq "Add member" | Where-Object Group -eq "CN=Group 1,DC=example,DC=com" | Where-Object Member -eq "CN=Group 5,DC=example,DC=com"
        $Operation.Member | Should -Be "CN=Group 5,DC=example,DC=com"
    }

    It "Should have a planned operation to add Group 4 to Group 1" {
        $Operation = $Operations | Where-Object Action -eq "Add member" | Where-Object Group -eq "CN=Group 1,DC=example,DC=com" | Where-Object Member -eq "CN=Group 4,DC=example,DC=com"
        $Operation.Member | Should -Be "CN=Group 4,DC=example,DC=com"
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

    It "Should have the correct count of planned operations" {
        $Operations.Count | Should -Be 7
    }
}