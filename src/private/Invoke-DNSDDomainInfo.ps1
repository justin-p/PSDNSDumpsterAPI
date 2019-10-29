Function Invoke-DNSDDomainInfo {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .LINK

    .EXAMPLE
    TBD
    .NOTES

    #>
    [CmdletBinding()]
    Param (
        [parameter( Mandatory= $true,
        ValueFromPipelineByPropertyName = $true)]
        $DNSDSession
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
    }
    Process {
        Try {
            Try {
                $ScanResults = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -Body $($DNSDSession.Body) -Method Post -WebSession $($DNSDSession.Session) -ContentType 'application/x-www-form-urlencoded' -Headers $($DNSDSession.Header)
            } Catch {
                Write-Error "$($FunctionName) - Unable to get results for domain '$($domain)' - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return (New-Object PSObject -Property @{ScanResults=$ScanResults;domain=$DNSDSession.body.targetip})
    }
}