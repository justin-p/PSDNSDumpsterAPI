Function New-DNSDSession {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER Domain
    TBD
    .LINK

    .EXAMPLE
    TBD
    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        $Domain
    )
    Begin {
        if ($PSCmdlet.ShouldProcess("Creating session to dnsdumpster.com")) {
            if ($script:ThisModuleLoaded -eq $true) {
                Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
            }
            $FunctionName = $MyInvocation.MyCommand.Name
            Write-Verbose "$($FunctionName) - Begin."
            Try {
                Try {
                    $login = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -SessionVariable session
                } Catch {
                    Write-Error "$($FunctionName) - Unable to create session to DNSDumpster.com - $PSItem"
                }
            } Catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
    Process {
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return $(New-Object PSObject -Property @{ DNSDSession=@{Body=@{csrfmiddlewaretoken = $($login.InputFields[0].value;);targetip = $Domain};
                                                  Header=@{Referer='https://dnsdumpster.com/';};
                                                  Session=$Session}})
    }
}