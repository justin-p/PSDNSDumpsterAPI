Function Get-PSDNSDumpsterAPIContent {
    <#
    .SYNOPSIS
    Get domain info content, such as excel or png, from DNSDumpster
    .DESCRIPTION
    Get domain info content, such as excel or png, from DNSDumpster
    .PARAMETER URL
    URL of excel: 'https://dnsdumpster.com/static/xls/justin-p.me-201910311359.xlsx'
    .EXAMPLE
    Get-PSDNSDumpsterAPIContent -URL 'https://dnsdumpster.com/static/xls/justin-p.me-201910311359.xlsx'
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Uri]$URL
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
        Write-Verbose "$($FunctionName) - Processing $URL"
        Try {
            Try {
                $Content = $(Invoke-WebRequest $URL).content
                If ($Content.GetType().Name -ne 'Byte[]') {
                    $Content = [System.Text.Encoding]::UTF8.GetBytes($Content)
                }
                $OutputObject += $(New-Object PSObject -Property @{url=$URL;ContentInBytesBase64Encoded=[System.Convert]::ToBase64String($Content);})
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