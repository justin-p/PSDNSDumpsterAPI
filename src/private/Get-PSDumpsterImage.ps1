Function Get-PSDumpsterImage {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .EXAMPLE
    TBD
    .EXAMPLE
    TBD
    .EXAMPLE
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory= $true,ValueFromPipeline = $true)]
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
        Write-Verbose "$($FunctionName) - Process $URL"
        Try {
            Try {
                $Content = $(Invoke-WebRequest $URL).content
                If ($Content.GetType().Name -ne 'Byte[]') {
                    $Content = [System.Text.Encoding]::UTF8.GetBytes($Content)
                }
                $OutputObject   += $(New-Object PSObject -Property @{url=$URL;ContentInBytes=$Content;})
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