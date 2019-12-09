Function Get-PSDNSDumpsterAPIResultsFromTable {
    <#
    .SYNOPSIS
    Parse the tables.
    .DESCRIPTION
    Parse the tables.
    .PARAMETER table
    Table to parse.
    .PARAMETER dns
    Parse as DNS table.
    .PARAMETER mx
    Parse as MX table.
    .PARAMETER txt
    Parse as txt table.
    .PARAMETER hosts
    Parse as hosts table.
    .EXAMPLE
    Get-PSDNSDumpsterAPIResultsFromTable -Table $tables[0] -dns
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        [PSObject]$table,
        [Switch]$dns,
        [Switch]$mx,
        [Switch]$txt,
        [Switch]$hosts
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        Try {
            Try {
                $trs = $table.SelectNodes($($table.xpath + "/tr"))
                $IPPattern = [Regex]::new('[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
                $resultObject = [Ordered] @{ }
                $OutputObject = @()
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    Process{
        Write-Verbose "$($FunctionName) - Processing $URL"
        Try {
            Try {
                ForEach ($tr in $trs) {
                    Try {
                        $tds = $tr.SelectNodes($($tr.xpath + "/td"))
                        $ip = $IPPattern.Matches($tds[1].InnerHtml).value
                        $domain = ($tds[0].InnerText.Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})
                        $reverse_dns = $tds[1].InnerText.Replace($IPPattern.Matches($tds[1].InnerHtml).value, '')
                        $country = $tds[2].InnerHTML.split('>').Split('<')[4]
                        $asn = $tds[2].InnerText.Replace($country,'')
                    } Catch {
                        Write-Debug "$($FunctionName) - $PSItem"
                    }
                    if ($dns) {
                        $resultObject['nameserver'] = $domain
                        $resultObject['ip'] = $ip
                        $resultObject['reversedns'] = $reverse_dns
                        $resultObject['asn'] = $asn
                        $resultObject['country'] = $country
                        $OutputObject +=[PSCustomObject] $resultObject
                    }
                    ElseIf ($mx) {
                        $resultObject['priority'] = $domain.split(' ')[0];
                        $resultObject['mx'] = $domain.split(' ')[1];
                        $resultObject['ip'] = $ip;
                        $resultObject['reversedns'] = $reverse_dns;
                        $resultObject['asn'] = $asn;
                        $resultObject['country'] = $country;
                        $OutputObject +=[PSCustomObject] $resultObject
                    }
                    ElseIf($txt) {
                        ForEach($td in $tds) {
                            $resultObject['TXTRecords'] = $td.InnerText.Replace("&quot;","`"")
                            $OutputObject +=[PSCustomObject] $resultObject
                        }
                    }
                    ElseIf($Hosts) {
                        if ($domain.getType().Name -ne 'string') {
                            $services    = @(($domain.Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"}))[(1..$($domain.Trim().split([Environment]::NewLine.Trim()) | Where-Object {$_ -notmatch "^$"}).count)]
                            $count = 1
                            $services = ForEach ($service in $services) {
                                if ($count % 2 -eq 1 ) {
                                    $service + " " + $services[$count]
                                }
                                $count++
                            }
                            $host_domain = $domain[0]
                        } Else {
                            $host_domain = $domain
                            $services = $null
                        }
                        $resultObject['host'] = $host_domain ;
                        $resultObject['services'] = $services;
                        $resultObject['ip'] = $ip;
                        $resultObject['reversedns'] = $reverse_dns;
                        $resultObject['asn'] = $asn;
                        $resultObject['country'] = $country;
                        $OutputObject +=[PSCustomObject] $resultObject
                    }
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