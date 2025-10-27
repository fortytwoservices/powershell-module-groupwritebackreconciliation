function Complete-GroupWritebackReconciliation {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Operation,

        [Parameter(Mandatory = $false)]
        [Switch] $Silent
    )

    Process {
        if ($Operation.Action -eq "Add member") {
            Write-Debug "Adding member '$($Operation.Member)' to group '$($Operation.Group)'."
            if (!$Silent.IsPresent) {
                $Operation | Show-GroupWritebackReconciliationOperation -Single
            }
            Add-ADGroupMember -Identity $Operation.Group -Members $Operation.Member
        }
        elseif ($Operation.Action -eq "Remove member") {
            Write-Debug "Removing member '$($Operation.Member)' from group '$($Operation.Group)'."
            if (!$Silent.IsPresent) {
                $Operation | Show-GroupWritebackReconciliationOperation -Single
            }
            Remove-ADGroupMember -Identity $Operation.Group -Members $Operation.Member -Confirm:$false
        }
        else {
            Write-Error "Unknown operation action '$($Operation.Action)'."
        }
    }
}