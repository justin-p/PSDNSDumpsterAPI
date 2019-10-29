Function Invoke-DNSDDomainInfo {
    Param (
        [parameter( Mandatory= $true,
        ValueFromPipelineByPropertyName = $true)]
        $DNSDSession
    )
    Begin {

    }
    Process {
        Try {
            $ScanResults = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -Body $($DNSDSession.Body) -Method Post -WebSession $($DNSDSession.Session) -ContentType 'application/x-www-form-urlencoded' -Headers $($DNSDSession.Header)
        } Catch {
            Write-Error $error[0]
        }
    }
    End {
        Return (New-Object PSObject -Property @{ScanResults=$ScanResults;domain=$DNSDSession.body.targetip})
    }
}