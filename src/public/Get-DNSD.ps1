Function Get-DNSD {
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
    Param(
        [Array]$Domains
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        $out=@()
    }
    Process {
        ForEach ($Domain in $Domains) {
            $Out += New-DNSDSession -domain $Domain | Invoke-DNSDDomainInfo | Parse-DNSDDomainInfo
        }
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return $out
    }
}