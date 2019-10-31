Function New-PSDNSDumpsterAPISession {
    <#
    .SYNOPSIS
    Create a session to dnsdumpster.com
    .DESCRIPTION
    Create a session to dnsdumpster.com. Return PSObject that can be used by Get-PSDNSDumpsterAPIDomainInfo.
    .PARAMETER DomainName
    Domain that will be added to 'targetip' in the POST request.
    .EXAMPLE
    New-PSDNSDumpsterAPISession -Domain 'justin-p.me'
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $DomainName
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        if ($PSCmdlet.ShouldProcess("Creating session to dnsdumpster.com")) {
            Try {
                Try {
                    Write-Verbose "$($FunctionName) - Creating session to 'https://dnsdumpster.com'"
                    $login = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -SessionVariable session
                } Catch {
                    Write-Error "$($FunctionName) - Unable to create session to 'https://dnsdumpster.com' - $PSItem"
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
        Return $(New-Object PSObject -Property @{DNSDumpsterSession=@{Body=@{csrfmiddlewaretoken = $($login.InputFields[0].value;);targetip = $DomainName};Header=@{Referer='https://dnsdumpster.com/';};Session=$Session}})
    }
}