Function Get-PSDNSDumpster {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER Domains
    TBD
    .LINK
    TBD
    .EXAMPLE
    TBD
    .NOTES
    TBD
    #>
    [CmdletBinding()]
    Param(
        [Array]$Domains
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        Try {
            Try {
                $OutputObject=@()
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    Process {
        Try {
            Try {
                ForEach ($DomainName in $Domains) {
                    $OutputObject += $DomainName | New-PSDumpsterSession | Get-PSDumpsterDomainInfo | Parse-PSDumpsterDomainInfo
                }
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Try {
            Try {
                Return $OutputObject
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}