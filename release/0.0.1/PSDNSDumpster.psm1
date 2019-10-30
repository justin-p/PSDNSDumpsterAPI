## Pre-Loaded Module code ##

<#
 Put all code that must be run prior to function dot sourcing here.

 This is a good place for module variables as well. The only rule is that no 
 variable should rely upon any of the functions in your module as they 
 will not have been loaded yet. Also, this file cannot be completely
 empty. Even leaving this comment is good enough.
#>

## PRIVATE MODULE FUNCTIONS AND DATA ##

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

Function Get-PSDumpsterDomainInfo {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER DNSDSession
    TBD
    .LINK
    TBD
    .EXAMPLE
    TBD
    .NOTES
    TBD
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory= $true,ValueFromPipelineByPropertyName = $true)]
        $DNSDSession
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
                $ScanResults = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -Body $($DNSDSession.Body) -Method Post -WebSession $($DNSDSession.Session) -ContentType 'application/x-www-form-urlencoded' -Headers $($DNSDSession.Header)
            } Catch {
                Write-Error "$($FunctionName) - Unable to get results for domain '$($DNSDSession.body.targetip)' - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return (New-Object PSObject -Property @{ScanResults=$ScanResults;DomainName=$DNSDSession.body.targetip;})
    }
}

Function Get-PSDumpsterImage {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .EXAMPLE
    TBD
    .EXAMPLE
    TBD
    .EXAMPLE
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory= $true,ValueFromPipeline = $true)]
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
        Write-Verbose "$($FunctionName) - Process $URL"
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

Function New-PSDumpsterSession {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER Domain
    TBD
    .LINK
    TBD
    .EXAMPLE
    TBD
    .NOTES
    TBD
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Mandatory= $true,ValueFromPipeline = $true)]
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
        Return $(New-Object PSObject -Property @{DNSDSession=@{Body=@{csrfmiddlewaretoken = $($login.InputFields[0].value;);targetip = $DomainName};Header=@{Referer='https://dnsdumpster.com/';};Session=$Session}})
    }
}

function Convert-PSDumpsterDomainInfo {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER Domain
    TBD
    .PARAMETER ScanResults
    TBD
    .LINK
    TBD
    .EXAMPLE
    TBD
    .NOTES
    TBD
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory= $true,ValueFromPipelineByPropertyName = $true)]
        $DomainName,
        [parameter(Mandatory= $true,ValueFromPipelineByPropertyName = $true)]
        $ScanResults
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
        Try {
            Try {
                $DNSObject  = @()
                $MXObject   = @()
                $TXTObject  = @()
                $HostObject = @()
            } Catch {
                Write-Error "$($FunctionName) - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    } Process {
        Try {
            Try {
                Write-Verbose "$($FunctionName) - Extract the tables out of the web request"
                $tables   = @($ScanResults.ParsedHtml.getElementsByTagName("TABLE"))
                $DNSRows  = $($tables[0]).Rows
                $MXRows   = $($tables[1]).Rows
                $TXTRows  = $($tables[2]).Rows
                $HostRows = $($tables[3]).Rows
            }
            Catch {
                Write-Error "$($FunctionName) - Unable to parse '`$ScanResults' - $PSItem"
            }
            Write-Verbose "$($FunctionName) - Go through all of the rows we defined."
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
                $ImageObject = Get-PSDumpsterImage -URL $("https://dnsdumpster.com/static/map/" + $DomainName + ".png")
            } Catch {
                Write-Error "$($FunctionName) - Unable to get image from DNSDumpster - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    } End {
        Write-Verbose "$($FunctionName) - End."
            Return $(New-Object psobject -Property @{DomainName=$DomainName;DNSDumpsterOutput=@{DNSObject=$DNSObject;MXObject=$MXObject;TXTObject=$TXTObject;HostObject=$HostObject;ImageObject=$ImageObject;}})
        }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

Function Get-PSDNSDumpster {
    <#
    .EXTERNALHELP PSDNSDumpster-help.xml
    .LINK
        https://github.com/justin-p/PSDNSDumpster/tree/master/release/0.0.1/docs/Functions/Get-PSDNSDumpster.md
    #>
    [CmdletBinding()]
    Param(
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
                    $DomainName | New-PSDumpsterSession | Get-PSDumpsterDomainInfo | Parse-PSDumpsterDomainInfo
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


