# Documentation for module Fortytwo.IAM.GroupWritebackReconciliation

A module for colsolidating AD groups with Entra ID in a write-back scenario.

## Installation

The module is published to the PowerShell gallery:

```PowerShell
Install-Module -Scope CurrentUser -Name Fortytwo.IAM.GroupWritebackReconciliation
```

## General

The module is invoked in three steps:

- Connect ([```Connect-GroupWritebackReconciliation```](Documentation.md#connect-GroupWritebackReconciliation)) the module to Entra ID, which is using the [EntraIDAccessToken](https://www.powershellgallery.com/packages/EntraIDAccessToken) module.
- Get required operations ([```Get-GroupWritebackReconciliationOperations```](Documentation.md#get-GroupWritebackReconciliationoperations)), which will return a list of operations that must be completed in order for your AD groups to have the same members as in Entra ID.
- Complete the operations using ([```Complete-GroupWritebackReconciliation```](Documentation.md#complete-GroupWritebackReconciliation))

## Examples

### Connect

The [```Connect-GroupWritebackReconciliation```](Documentation.md#connect-GroupWritebackReconciliation) cmdlet is used to tell the module how to connect to Entra ID, and how to locate AD groups.

```PowerShell
Connect-GroupWritebackReconciliation
```

```PowerShell
Add-EntraIDInteractiveUserAccessTokenProfile -Name "test"
Connect-GroupWritebackReconciliation `
    -AccessTokenProfile "test" `
    -ADGroupFilter { adminDescription -like "TakenOver_Group_*" }
```

### Get and show operations

The [```Get-GroupWritebackReconciliationOperations```](Documentation.md#get-GroupWritebackReconciliationoperations) cmdlet is used to calculate the required operations in Entra ID and Active Directory.

```PowerShell
$Operations = Get-GroupWritebackReconciliationOperations -Verbose
$Operations | Show-GroupWritebackReconciliationOperation
```

### Complete operations

The last step is to actually complete the operations into AD.

```PowerShell
$Operations | Complete-GroupWritebackReconciliation
```

### Complete examples

- [Example 1.ps1](Example%201.ps1)