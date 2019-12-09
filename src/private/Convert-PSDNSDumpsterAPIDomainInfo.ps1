function Convert-PSDNSDumpsterAPIDomainInfo {
    <#
    .SYNOPSIS
    Create a parsed output from DNSDumpster.
    .DESCRIPTION
    Create a parsed output from DNSDumpster. This functions expects a PSObject created by Get-PSDNSDumpsterAPIDomainInfo.
    .PARAMETER DomainName
    The name of the domain.
    .PARAMETER ScanResults
    Results of Get-PSDNSDumpsterAPIDomainInfo
    .EXAMPLE
    New-PSDNSDumpsterAPISession -Domain 'justin-p.me' | Get-PSDNSDumpsterAPIDomainInfo | Convert-PSDNSDumpsterAPIDomainInfo
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $DomainName,
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $ScanResults,
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $DNSDumpsterSession
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        Try {
            Try {

            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    } Process {
        Write-Verbose "$($FunctionName) - Processing '$DomainName'"
        Try {
            $doc = New-Object HtmlAgilityPack.HtmlDocument
            $doc.LoadHtml($ScanResults)
            $tables = $doc.DocumentNode.SelectNodes("//table")
            $a = $doc.DocumentNode.SelectNodes("//a").Attributes.Value
            $PNGLink = "https://dnsdumpster.com" + $($a | Where-Object {$_ -match 'png'})
            $ExcelLink = "https://dnsdumpster.com" + $($a | Where-Object {$_ -match '.xlsx'})
            Try {
                $DNSObject = Get-PSDNSDumpsterAPIResultsFromTable -Table $tables[0] -dns
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse DNS Table - $PSItem"
            }
            Try {
                $MXObject = Get-PSDNSDumpsterAPIResultsFromTable -Table $tables[1] -mx
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse MX Table - $PSItem"
            }
            Try {
                $TXTObject = Get-PSDNSDumpsterAPIResultsFromTable -Table $tables[2] -txt
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse TXT Table - $PSItem"
            }
            Try {
                $HostObject = Get-PSDNSDumpsterAPIResultsFromTable -Table $tables[3] -hosts
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse Hosts Table - $PSItem"
            }
            Try {
                $ImageObject = Get-PSDNSDumpsterAPIContent -URL $PNGLink
            } Catch {
                Write-Error "$($FunctionName) - Unable to get image from DNSDumpster - $PSItem"
            }
            Try {
                $ExcelObject = Get-PSDNSDumpsterAPIContent -URL $ExcelLink
            } Catch {
                Write-Error "$($FunctionName) - Unable to get excel from DNSDumpster - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    } End {
        Write-Verbose "$($FunctionName) - End."
            Return $(New-Object psobject -Property @{DomainName=$DomainName;DNSDumpsterObject=@{DNS=$DNSObject;MX=$MXObject;TXT=$TXTObject;Host=$HostObject;Image=$ImageObject;Excel=$ExcelObject};DNSDumpsterSession=$DNSDumpsterSession;})
    }
}