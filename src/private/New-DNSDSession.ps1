Function New-DNSDSession {
    Param (
        $Domain
    )
    Begin {
        Try {
            $login = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -SessionVariable session
        } Catch {
            Write-Error "Unable to create session to DNSDumpster.com"
        }

    }
    Process {
    }
    End {
        Return $(New-Object PSObject -Property @{ DNSDSession=@{Body=@{csrfmiddlewaretoken = $($login.InputFields[0].value;);targetip = $Domain};
                                                  Header=@{Referer='https://dnsdumpster.com/';};
                                                  Session=$Session}})
    }
}