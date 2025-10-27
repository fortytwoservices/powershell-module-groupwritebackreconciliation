<#
.SYNOPSIS
Prints all planned operations to screen

.EXAMPLE
$Operations | Show-GroupWritebackReconciliationOperation
#>
function Show-GroupWritebackReconciliationOperation {
    [CmdletBinding(SupportsShouldProcess = $true)]

    Param(
        # The operation to show
        [Parameter(ValueFromPipeline = $true)]
        $Operation,

        [Parameter()]
        [Switch] $Single
    )

    Begin {
        if (!$Single.IsPresent) {
            $Script:PreviousGroup = $null
            Write-Host "[group]Operations report"
        }

        $Methods = [ordered] @{
            "Add member"    = 0
            "Remove member" = 0
        }
    }

    Process {
        $Methods[$Operation.Action] += 1

        if($Script:PreviousGroup -ne $Operation.Group) {
            if ($Script:PreviousGroup) {
                Write-Host ""
            }
            Write-Host "Group: $($Operation.Group)"
            $Script:PreviousGroup = $Operation.Group
        }

        if ($Operation.Action -eq "Add member") {
            Write-Host "    + $($PSStyle.Foreground.Green)$($Operation.Member)$($PSStyle.Reset)"
        }
        elseif ($Operation.Action -eq "Remove member") {
            Write-Host "    - $($PSStyle.Foreground.Red)$($Operation.Member)$($PSStyle.Reset)"
        }
        else {
            Write-Warning "Unknown operation action '$($Operation.Action)'."
        }
    }

    End {
        if (!$Single.IsPresent) {
            Write-Host "[endgroup]"
        
            Write-Host "Operations summary:"
            $Methods.GetEnumerator() | ForEach-Object {
                $Color = $PSStyle.Foreground.Green
                $Color = $_.Key -eq "Remove member" ? $PSStyle.Foreground.BrightRed : $Color
                $Color = $_.Key -eq "Add member" ? $PSStyle.Foreground.BrightGreen : $Color

                Write-Host " - $($_.Value) x $($Color)$($_.Key)$($PSStyle.Reset)"
            }
            $Script:PreviousGroup = $null
        }
    }
}