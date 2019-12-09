$DomainTestObject = 'apple.com' | New-PSDNSDumpsterAPISession | Get-PSDNSDumpsterAPIDomainInfo

$doc = New-Object HtmlAgilityPack.HtmlDocument
$doc.LoadHtml($DomainTestObject.ScanResults)
$tables = $doc.DocumentNode.SelectNodes("//table")

Function Get-ResultsFromTable {
    Param(
        $table,
        [switch]$dns,
        [switch]$mx,        
        [switch]$txt,
        [switch]$Hosts
    )
    $trs =  $table.SelectNodes($($table.xpath + "/tr"))
    $IPPattern = [Regex]::new('[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    $resultObject = [Ordered] @{ }
    $outputObject = @()
    ForEach ($tr in $trs) {
        Try { 
            $tds         = $tr.SelectNodes($($tr.xpath + "/td"))
            $ip          = $IPPattern.Matches($tds[1].InnerHtml).value
            $domain      = ($tds[0].InnerText.Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})
            $reverse_dns = $tds[1].InnerText.Replace($IPPattern.Matches($tds[1].InnerHtml).value, '')
            $country     = $tds[2].InnerHTML.split('>').Split('<')[4]
            $asn         = $tds[2].InnerText.Replace($country,'')
        } Catch {
            #
        }
        if ($dns) {
            $resultObject['nameserver'] = $domain
            $resultObject['ip']         = $ip
            $resultObject['reversedns'] = $reverse_dns
            $resultObject['asn']        = $asn
            $resultObject['country']    = $country
            $outputObject +=[PSCustomObject] $resultObject
        }        
        ElseIf ($mx) {
            $resultObject['priority']   = $domain.split(' ')[0];
            $resultObject['mx']         = $domain.split(' ')[1];
            $resultObject['ip']         = $ip;
            $resultObject['reversedns'] = $reverse_dns;
            $resultObject['asn']        = $asn;
            $resultObject['country']    = $country;
            $outputObject +=[PSCustomObject] $resultObject
        }
        ElseIf($txt) {
            ForEach($td in $tds) {
                $resultObject['TXTRecords'] = $td.InnerText.Replace("&quot;","`"")
                $outputObject +=[PSCustomObject] $resultObject
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
            $resultObject['host']       = $host_domain ;
            $resultObject['services']   = $services;
            $resultObject['ip']         = $ip;
            $resultObject['reversedns'] = $reverse_dns;
            $resultObject['asn']        = $asn;
            $resultObject['country']    = $country;
            $outputObject +=[PSCustomObject] $resultObject
        }
    }
    $outputObject
}

$DNSObject = Get-ResultsFromTable -table $tables[0] -dns
$MXObject = Get-ResultsFromTable -table $tables[1] -mx
$TXTObject = Get-ResultsFromTable -table $tables[2] -txt
$HostObject = Get-ResultsFromTable -table $tables[3] -hosts
$out =  $(New-Object psobject -Property @{DomainName=$DomainName;DNSDumpsterObject=@{DNS=$DNSObject;MX=$MXObject;TXT=$TXTObject;Host=$HostObject;}})
$out.DNSDumpsterObject.DNS | ft -AutoSize
$out.DNSDumpsterObject.MX | ft -AutoSize
$out.DNSDumpsterObject.TXT | ft -AutoSize
$out.DNSDumpsterObject.Host | ft -AutoSize