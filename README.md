# Documentation for module Fortytwo.IAM.GroupWritebackConsolidation

A module for colsolidating AD groups with Entra ID in a write-back scenario.

## Installation

The module is published to the PowerShell gallery:

```PowerShell
Install-Module -Scope CurrentUser -Name Fortytwo.IAM.GroupWritebackConsolidation
```

## General

The module is invoked in three steps:

- Connect ([```Connect-GroupWritebackConsolidation```](Documentation.md#connect-groupwritebackconsolidation)) the module to Entra ID, which is using the [EntraIDAccessToken](https://www.powershellgallery.com/packages/EntraIDAccessToken) module.
- Get required operations ([```Get-GroupWritebackConsolidationOperations```](Documentation.md#get-groupwritebackconsolidationoperations)), which will return a list of operations that must be completed in order for your AD groups to have the same members as in Entra ID.
- Complete the operations using ([```Complete-GroupWritebackConsolidation```](Documentation.md#complete-groupwritebackconsolidation))

## Examples

### Connect

The [```Connect-GroupWritebackConsolidation```](Documentation.md#connect-groupwritebackconsolidation) cmdlet is used to tell the module how to connect to Entra ID, and how to locate AD groups.

```PowerShell
Connect-GroupWritebackConsolidation
```

```PowerShell
Add-EntraIDInteractiveUserAccessTokenProfile -Name "test"
Connect-GroupWritebackConsolidation `
    -AccessTokenProfile "test" `
    -ADGroupFilter { adminDescription -like "takenover_*" }
```

### Get and show operations

The [```Get-GroupWritebackConsolidationOperations```](Documentation.md#get-groupwritebackconsolidationoperations) cmdlet is used to calculate the required operations in Entra ID and Active Directory.

```PowerShell
$Operations = Get-GroupWritebackConsolidationOperations -Verbose
$Operations | Show-GroupWritebackConsolidationOperation
```

### Complete operations

The last step is to actually complete the operations into AD.

```PowerShell
$Operations | Complete-GroupWritebackConsolidation
```

### Complete examples

- [Example 1.ps1](Example%201.ps1)