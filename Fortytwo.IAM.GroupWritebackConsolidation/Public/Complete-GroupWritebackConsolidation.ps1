function Complete-GroupWritebackConsolidation {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Operation
    )

    Process {
        if ($Operation.Action -eq "Add member") {
            Add-ADGroupMember -Identity $Operation.Group -Members $Operation.Member
        }
        elseif ($Operation.Action -eq "Remove member") {
            Remove-ADGroupMember -Identity $Operation.Group -Members $Operation.Member -Confirm:$false
        }
        else {
            Write-Error "Unknown operation action '$($Operation.Action)'."
        }
    }
}