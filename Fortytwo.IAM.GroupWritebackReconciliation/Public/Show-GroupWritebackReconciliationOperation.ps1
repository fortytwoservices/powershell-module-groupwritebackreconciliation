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

        [Parameter(Mandatory = $false)]
        [Switch] $Single
    )

    Begin {
        if (!$Single.IsPresent) {
            $Script:PreviousGroup = $null
            if ($env:TF_BUILD -eq "True") {
                Write-Host "[group]Operations report"
            } elseif($env:GITHUB_ACTIONS -eq "true") {
                Write-Host "::group::Operations report"
            } else {
                Write-Host "Operations report:"
            }
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
            if ($env:TF_BUILD -eq "True") {
                Write-Host "[endgroup]"
            } elseif($env:GITHUB_ACTIONS -eq "true") {
                Write-Host "::endgroup::"
            }
        
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