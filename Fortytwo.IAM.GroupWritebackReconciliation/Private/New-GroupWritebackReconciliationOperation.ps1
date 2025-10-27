function New-GroupWritebackReconciliationOperation {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Add member", "Remove member")]
        [string]$Action,

        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [string]$Member
    )

    Process {
        return [PSCustomObject]@{
            Action = $Action
            Group = $Group
            Member = $Member
        }
    }
}