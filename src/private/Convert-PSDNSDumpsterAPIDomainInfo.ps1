function Convert-PSDNSDumpsterAPIDomainInfo {
    <#
    .SYNOPSIS
    Parse the output from DNSDumpster to a PSObject.
    .DESCRIPTION
    Parse the output from DNSDumpster to a PSObject. This functions expects a PSObject created by Get-PSDNSDumpsterAPIDomainInfo.
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
                $DNSObject   = @()
                $MXObject    = @()
                $TXTObject   = @()
                $HostObject  = @()
                #$ExcelObject = @()
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    } Process {
        Write-Verbose "$($FunctionName) - Processing '$DomainName'"
        Try {
            Try {
                Write-Debug "$($FunctionName) - Extract info out of the web request"
                $tables    = @($ScanResults.ParsedHtml.getElementsByTagName("TABLE"))
                #$a         = @($ScanResults.ParsedHtml.getElementsByTagName("A"))
                $DNSRows   = $($tables[0]).Rows
                $MXRows    = $($tables[1]).Rows
                $TXTRows   = $($tables[2]).Rows
                $HostRows  = $($tables[3]).Rows
                #$ExcelHref = $a[24]
            }
            Catch {
                Write-Error "$($FunctionName) - Unable to parse '`$ScanResults' - $PSItem"
            }
            Write-Debug "$($FunctionName) - Go through all of the rows we defined."
            Try {
                ForEach ($row in $DNSRows) {
                    $cells = @($row.Cells)
                    $resultObject = [Ordered] @{ }
                    $resultObject["nameserver"] = @(""  + $cells[0].InnerText).Trim().TrimEnd('.')
                    $resultObject["ip"]         = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["reversedns"] = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
                    $resultObject["asn"]        = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["country"]    = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
                    $DNSObject +=[PSCustomObject] $resultObject
                }
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse '`$DNSRows'- $PSItem"
            }
            Try {
                ForEach ($row in $MXRows) {
                    $cells = @($row.Cells)
                    $resultObject = [Ordered] @{ }
                    $resultObject["priority"]   = @((""  + $cells[0].InnerText).Trim().split(" ") | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["mx"]         = @((("" + $cells[0].InnerText).Trim().split(" ") | Where-Object {$_ -notmatch "^$"})[1]).TrimEnd('.')
                    $resultObject["ip"]         = @((""  + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["reversedns"] = @((""  + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
                    $resultObject["asn"]        = @((""  + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["country"]    = @((""  + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
                    $MXObject +=[PSCustomObject] $resultObject
                }
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse '`$MXRows'- $PSItem"
            }
            Try {
                ForEach ($row in $TXTRows) {
                    $TXTObject +=$row.InnerText
                }
                $TXTObject = New-Object PSObject -property @{TXTRecords=$TXTObject}
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse '`$TXTRows'- $PSItem"
            }
            Try {
                ForEach ($row in $HostRows) {
                    $cells = @($row.Cells)
                    $resultObject = [Ordered] @{ }
                    $resultObject["host"]       = @(("" + $cells[0].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["services"]   = @(("" + $cells[0].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[(2..(("" + $cells[0].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"}).count)]
                    $resultObject["ip"]         = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["reversedns"] = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
                    $resultObject["asn"]        = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
                    $resultObject["country"]    = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
                    $HostObject +=[PSCustomObject] $resultObject
                }
            } Catch {
                Write-Error "$($FunctionName) - Unable to parse '`$HostRows'- $PSItem"
            }
            Try {
                $ImageObject = Get-PSDNSDumpsterAPIImage -URL $("https://dnsdumpster.com/static/map/" + $DomainName + ".png")
            } Catch {
                Write-Error "$($FunctionName) - Unable to get image from DNSDumpster - $PSItem"
            }
            Try {
                $ExcelObject = Get-PSDNSDumpsterAPIExcel -URL $("https://dnsdumpster.com/" + "$($ExcelHref.pathname)")
            } Catch {
                Write-Error "$($FunctionName) - Unable to get excel from DNSDumpster - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    } End {
        Write-Verbose "$($FunctionName) - End."
            Return $(New-Object psobject -Property @{DomainName=$DomainName;DNSDumpsterObject=@{DNS=$DNSObject;MX=$MXObject;TXT=$TXTObject;Host=$HostObject;Image=$ImageObject;};DNSDumpsterSession=$DNSDumpsterSession;})
        }
}