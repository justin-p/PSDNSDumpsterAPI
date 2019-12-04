$doc = New-Object HtmlAgilityPack.HtmlDocument
$doc.LoadHtml($Domain.ScanResults)

#$tables    = @($doc.DocumentNode.SelectNodes("//table[@class='table']"))
#$Rows      = $tables.SelectNodes('tr')

#$DNSRows   = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr")
#$MXRows    = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[5]")
#$TXTRows   = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[6]")
#$HostRows  = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[7]")
#
#$nameserver = ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[1]/td").Childnodes)[0].innertext
#$ip         = ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[1]/td").Childnodes)[15].innertext
#$reverse    = ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[1]/td").Childnodes)[17].innertext
#$asn        = ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[1]/td").Childnodes)[18].innertext



ForEach ($tr in ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr")).count) {
    #$resultObject = [Ordered] @{ }
    #$resultObject["nameserver"]
    ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[$tr]/td").Childnodes)[0].innertext.TrimEnd('.')
    ##$resultObject["ip"] 
    ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[$tr]/td").Childnodes)[15].innertext
    ##$resultObject["reversedns"]
    ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[$tr]/td").Childnodes)[17].innertext
    ##$resultObject["asn"] 
    ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[$tr]/td").Childnodes)[18].innertext
    ##$resultObject["country"] 
    ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr[$tr]/td").Childnodes)[20].innertext
    ##$DNSObject +=[PSCustomObject] $resultObject
}

ForEach ($tr in ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[4]/table[1]/tr").count)) {
    #$resultObject = [Ordered] @{ }
    #$resultObject["priority"]   
    #$resultObject["mx"]         
    #$resultObject["ip"]         
    #$resultObject["reversedns"] 
    #$resultObject["asn"]        
    #$resultObject["country"]    
    #$MXObject +=[PSCustomObject] $resultObject
}

ForEach ($tr in ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[6]/table[1]/tr").count)) {
    $doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[6]/table[1]/tr[$tr]/td").innertext
}

ForEach ($tr in ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[7]/table[1]/tr").count)) {
    #$resultObject = [Ordered] @{ }
    #$resultObject["host"]       
    ($doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[7]/table[1]/tr[$tr]/td").Childnodes)[0].innertext
    #$resultObject["services"]
    #$resultObject["ip"]         
    #$resultObject["reversedns"] 
    $doc.DocumentNode.SelectNodes("/html[1]/body[1]/div[1]/div[1]/section[1]/div[1]/div[3]/div[1]/div[7]/table[1]/tr[$tr]/td")
    #$resultObject["asn"]        
    #$resultObject["country"]    
    #$HostObject +=[PSCustomObject] $resultObject
}