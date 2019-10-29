Function Get-DNSD {
    Param(
        [Array]$Domains
    )
    Begin {
        $out=@()
    }
    Process {
        ForEach ($Domain in $Domains) {
            $Out += New-DNSDSession -domain $Domain | Invoke-DNSDDomainInfo | Parse-DNSDDomainInfo
        }
    }
    End {
        return $out
    }
}