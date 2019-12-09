## Pre-Loaded Module code ##

<#
 Put all code that must be run prior to function dot sourcing here.

 This is a good place for module variables as well. The only rule is that no 
 variable should rely upon any of the functions in your module as they 
 will not have been loaded yet. Also, this file cannot be completely
 empty. Even leaving this comment is good enough.
#>

## PRIVATE MODULE FUNCTIONS AND DATA ##

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
            $doc = New-Object HtmlAgilityPack.HtmlDocument
            $doc.LoadHtml($ScanResults)
            $tables = $doc.DocumentNode.SelectNodes("//table")
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
                $ImageObject = Get-PSDNSDumpsterAPIImage -URL $("https://dnsdumpster.com/static/map/" + $DomainName + ".png")
            } Catch {
                Write-Error "$($FunctionName) - Unable to get image from DNSDumpster - $PSItem"
            }
            Try {
                #$ExcelObject = Get-PSDNSDumpsterAPIExcel -URL $("https://dnsdumpster.com/" + "$($ExcelHref.pathname)")
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

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]$SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]$Name
    )

    begin {
        $filterHash = @{}
    }
    
    process {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator()) {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name))) {
                
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable) {
                    if ($SessionState -eq $ExecutionContext.SessionState) {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered') {
            foreach ($varName in $filterHash.Keys) {
                if (-not $vars.ContainsKey($varName)) {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }
    }
}

Function Get-PSDNSDumpsterAPIDomainInfo {
    <#
    .SYNOPSIS
    Get domain info from DNSDumpster.
    .DESCRIPTION
    Get domain info from DNSDumpster. This functions expects a PSObject created by New-PSDNSDumpsterAPISession.
    .PARAMETER DNSDSession
    PSObject created by New-PSDNSDumpsterAPISession
    .EXAMPLE
    New-PSDNSDumpsterAPISession -Domain 'justin-p.me' | Get-PSDNSDumpsterAPIDomainInfo
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $DNSDumpsterSession
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
    }
    Process {
        Try {
            Try {
                Write-Verbose "$($FunctionName) - Processing '$($DNSDumpsterSession.body.targetip)'"
                $ScanResults = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -Body $($DNSDumpsterSession.Body) -Method Post -WebSession $($DNSDumpsterSession.Session) -ContentType 'application/x-www-form-urlencoded' -Headers $($DNSDumpsterSession.Header)
            } Catch {
                Write-Error "$($FunctionName) - Unable to get results for domain '$($DNSDumpsterSession.body.targetip)' - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return (New-Object PSObject -Property @{ScanResults=$ScanResults;DomainName=$DNSDumpsterSession.body.targetip;DNSDumpsterSession=$DNSDumpsterSession})
    }
}

Function Get-PSDNSDumpsterAPIExcel {
    <#
    .SYNOPSIS
    Get domain info excel from DNSDumpster
    .DESCRIPTION
    Get domain info excel from DNSDumpster
    .PARAMETER URL
    URL of excel: 'https://dnsdumpster.com/static/xls/justin-p.me-201910311359.xlsx'
    .EXAMPLE
    et-PSDNSDumpsterAPIImage -URL 'https://dnsdumpster.com/static/xls/justin-p.me-201910311359.xlsx'
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Uri]$URL
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
        Write-Verbose "$($FunctionName) - Processing $URL"
        Try {
            Try {
                $Content = $(Invoke-WebRequest $URL).content
                If ($Content.GetType().Name -ne 'Byte[]') {
                    $Content = [System.Text.Encoding]::UTF8.GetBytes($Content)
                }
                $OutputObject += $(New-Object PSObject -Property @{url=$URL;ContentInBytes=$Content;})
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

Function Get-PSDNSDumpsterAPIImage {
    <#
    .SYNOPSIS
    Get domain info image from DNSDumpster
    .DESCRIPTION
    Get domain info image from DNSDumpster
    .PARAMETER URL
    URL of image: 'https://dnsdumpster.com/static/map/justin-p.me.png'
    .EXAMPLE
    et-PSDNSDumpsterAPIImage -URL 'https://dnsdumpster.com/static/map/justin-p.me.png'
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Uri]$URL
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
        Write-Verbose "$($FunctionName) - Processing $URL"
        Try {
            Try {
                $Content = $(Invoke-WebRequest $URL).content
                If ($Content.GetType().Name -ne 'Byte[]') {
                    $Content = [System.Text.Encoding]::UTF8.GetBytes($Content)
                }
                $OutputObject   += $(New-Object PSObject -Property @{url=$URL;ContentInBytes=$Content;})
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

Function New-PSDNSDumpsterAPISession {
    <#
    .SYNOPSIS
    Create a session to dnsdumpster.com
    .DESCRIPTION
    Create a session to dnsdumpster.com. Return PSObject that can be used by Get-PSDNSDumpsterAPIDomainInfo.
    .PARAMETER DomainName
    Domain that will be added to 'targetip' in the POST request.
    .EXAMPLE
    New-PSDNSDumpsterAPISession -Domain 'justin-p.me'
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $DomainName
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        if ($PSCmdlet.ShouldProcess("Creating session to dnsdumpster.com")) {
            Try {
                Try {
                    Write-Verbose "$($FunctionName) - Creating session to 'https://dnsdumpster.com'"
                    $login = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -SessionVariable session
                } Catch {
                    Write-Error "$($FunctionName) - Unable to create session to 'https://dnsdumpster.com' - $PSItem"
                }
            } Catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
    Process {
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return $(New-Object PSObject -Property @{DNSDumpsterSession=@{Body=@{csrfmiddlewaretoken = $($login.InputFields[0].value;);targetip = $DomainName};Header=@{Referer='https://dnsdumpster.com/';};Session=$Session}})
    }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

Function Invoke-PSDNSDumpsterAPI {
    <#
    .EXTERNALHELP PSDNSDumpsterAPI-help.xml
    .LINK
        https://github.com/justin-p/PSDNSDumpsterAPI/tree/master/release/0.0.3/docs/Functions/Invoke-PSDNSDumpsterAPI.md
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


## Post-Load Module code ##

# Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it will work in testing and after being built
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
        }
    }

    Get-ScriptPath
)

# Load any plugins found in the plugins directory
if (Test-Path (Join-Path $MyModulePath 'plugins')) {
    Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName "Load.ps1")) {
            Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "Load.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
        }
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    # Action to take if the module is removed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
            }
        }
    }
}

$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock [Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}") -ErrorVariable errmsg 2>$null
            }
        }
    }
}

# Use this in your scripts to check if the function is being called from your module or independantly.
# Call it immediately to avoid PSScriptAnalyzer 'PSUseDeclaredVarsMoreThanAssignments'
$ThisModuleLoaded = $true
$ThisModuleLoaded

# Non-function exported public module members might go here.
#Export-ModuleMember -Variable SomeVariable -Function  *


