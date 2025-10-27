# Documentation for module Fortytwo.IAM.GroupWritebackReconciliation

A module for group writeback consolidation in Entra ID.

| Metadata | Information |
| --- | --- |
| Version | 0.4.1 |
| Required modules | EntraIDAccessToken |
| Author | Marius Solbakken Mellum |
| Company name | Fortytwo Technologies AS |
| PowerShell version | 7.2 |

## Complete-GroupWritebackReconciliation

### SYNOPSIS
{{ Fill in the Synopsis }}

### SYNTAX

```
Complete-GroupWritebackReconciliation [[-Operation] <Object>] [-Silent] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### DESCRIPTION


### EXAMPLES

#### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

### PARAMETERS

#### -Operation


```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

#### -Silent


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -ProgressAction


```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

### INPUTS

#### System.Object
### OUTPUTS

#### System.Object
### NOTES

### RELATED LINKS
## Connect-GroupWritebackReconciliation

### SYNOPSIS
Connects the Connect-GroupWritebackReconciliation module to Entra ID and Active Directory.

### SYNTAX

```
Connect-GroupWritebackReconciliation [[-AccessTokenProfile] <String>] [-SkipAllTests]
 [[-ADGroupFilter] <ScriptBlock>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### DESCRIPTION
Connects the Connect-GroupWritebackReconciliation module to Entra ID and Active Directory.

### EXAMPLES

#### EXAMPLE 1
```
Install-Module Fortytwo.IAM.GroupWritebackReconciliation -Scope CurrentUser
```

Add-EntraIDClientSecretAccessTokenProfile \`
    -TenantId "bb73082a-b74c-4d39-aec0-41c77d6f4850" \`
    -ClientId "78f07963-ce55-4b23-b56a-2e13f2036d7f"

Connect-GroupWritebackReconciliation

### PARAMETERS

#### -AccessTokenProfile
Access token profile to use for authentication.
the EntraIDAccessToken module must be installed and imported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

#### -SkipAllTests
Skips all tests when connecting.
Use with caution.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

#### -ADGroupFilter


```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: { adminDescription -like "TakenOver_Group_*" }
Accept pipeline input: False
Accept wildcard characters: False
```

#### -ProgressAction


```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

### INPUTS

### OUTPUTS

### NOTES

### RELATED LINKS
## Get-GroupWritebackReconciliationOperations

### SYNOPSIS
{{ Fill in the Synopsis }}

### SYNTAX

```
Get-GroupWritebackReconciliationOperations [-DoNotWarnIfMissingOnPremDN] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### DESCRIPTION


### EXAMPLES

#### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

### PARAMETERS

#### -DoNotWarnIfMissingOnPremDN


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -ProgressAction


```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

### INPUTS

#### None
### OUTPUTS

#### System.Object
### NOTES

### RELATED LINKS
## Show-GroupWritebackReconciliationOperation

### SYNOPSIS
Prints all planned operations to screen

### SYNTAX

```
Show-GroupWritebackReconciliationOperation [[-Operation] <Object>] [-Single]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### DESCRIPTION


### EXAMPLES

#### EXAMPLE 1
```
$Operations | Show-GroupWritebackReconciliationOperation
```

### PARAMETERS

#### -Operation
The operation to show

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

#### -Single


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

#### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### -ProgressAction


```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

#### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

### INPUTS

### OUTPUTS

### NOTES

### RELATED LINKS
