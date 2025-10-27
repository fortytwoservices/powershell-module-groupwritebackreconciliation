function Complete-GroupWritebackReconciliation {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Operation
    )

    Process {
        if ($Operation.Action -eq "Add member") {
            $Operation | Show-GroupWritebackReconciliationOperation -Single
            Add-ADGroupMember -Identity $Operation.Group -Members $Operation.Member
        }
        elseif ($Operation.Action -eq "Remove member") {
            $Operation | Show-GroupWritebackReconciliationOperation -Single
            Remove-ADGroupMember -Identity $Operation.Group -Members $Operation.Member -Confirm:$false
        }
        else {
            Write-Error "Unknown operation action '$($Operation.Action)'."
        }
    }
}