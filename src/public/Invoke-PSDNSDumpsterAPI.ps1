Function Invoke-PSDNSDumpsterAPI {
    <#
    .SYNOPSIS
    Send a webrequest to DNSDumpster, parse output and return it as a PSObject.
    .DESCRIPTION
    Send a webrequest to DNSDumpster, parse output and return it as a PSObject.
    .PARAMETER Domains
    One or more domains to get DNSDumpster results for.
    .LINK
    https://github.com/justin-p/PSDNSDumpsterAPI
    .EXAMPLE
    Invoke-PSDNSDumpsterAPI -Domains 'justin-p.me'
    DNSDumpsterObject        DomainName
    -----------------        ----------
    {DNS, TXT, MX, Image...} justin-p.me
    .EXAMPLE
    Invoke-PSDNSDumpsterAPI -Domains 'justin-p.me','reddit.com','youtube.com'
    DNSDumpsterObject        DomainName
    -----------------        ----------
    {DNS, TXT, MX, Image...} justin-p.me
    {DNS, TXT, MX, Image...} reddit.com
    {DNS, TXT, MX, Image...} youtube.com
    .EXAMPLE
    'microsoft.com','google.com' | Invoke-PSDNSDumpsterAPI
    DNSDumpsterObject        DomainName
    -----------------        ----------
    {DNS, TXT, MX, Image...} microsoft.com
    {DNS, TXT, MX, Image...} google.com
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI

    ContentInBytes to PNG file:
    To turn the Image Byte array (ContentInBytes) to a png file run the following set of commands:
    $domain = Invoke-PSDNSDumpsterAPI -Domains "justin-p.me"
    $domain.DNSDumpsterOutput.Image.ContentInBytes | Set-Content -Encoding Byte -Path c:\path\to\file.png
    #>
    [CmdletBinding()]
    Param(
        [parameter(Mandatory= $true,ValueFromPipeline = $true)]
        [Array]$Domains
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        Try {
            Try {
                $OutputObject=@()
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    Process {
        Try {
            Try {
                ForEach ($DomainName in $Domains) {
                    $DomainName = $($DomainName).ToLower()
                    Write-Verbose "$($FunctionName) - Processing '$DomainName'"
                    $OutputObject += $DomainName | New-PSDNSDumpsterAPISession | Get-PSDNSDumpsterAPIDomainInfo | Convert-PSDNSDumpsterAPIDomainInfo
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