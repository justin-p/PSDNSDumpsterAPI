Function New-PSDumpsterSession {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER Domain
    TBD
    .LINK
    TBD
    .EXAMPLE
    TBD
    .NOTES
    TBD
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Mandatory= $true,ValueFromPipeline = $true)]
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
        Return $(New-Object PSObject -Property @{DNSDSession=@{Body=@{csrfmiddlewaretoken = $($login.InputFields[0].value;);targetip = $DomainName};Header=@{Referer='https://dnsdumpster.com/';};Session=$Session}})
    }
}