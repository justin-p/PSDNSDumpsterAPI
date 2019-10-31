#Requires -Version 5
[CmdletBinding(DefaultParameterSetName = 'Build')]
param (
    [parameter(Position = 0, ParameterSetName = 'Build')]
    [switch]$BuildModule,
    [parameter(Position = 2, ParameterSetName = 'Build')]
    [switch]$UploadPSGallery,
    [parameter(Position = 3, ParameterSetName = 'Build')]
    [switch]$InstallAndTestModule,
    [parameter(Position = 4, ParameterSetName = 'Build')]
    [version]$NewVersion,
    [parameter(Position = 5, ParameterSetName = 'Build')]
    [string]$ReleaseNotes,
    [parameter(Position = 6, ParameterSetName = 'Build')]
    [string]$AppVeyor,
    [parameter(Position = 7, ParameterSetName = 'CBH')]
    [switch]$AddCBH
)

function PrerequisitesLoaded {
    # Install required modules if missing
    try {
        if ($null -eq (get-module InvokeBuild -ListAvailable)) {
            Write-Output -InputObject "Attempting to install the InvokeBuild module..."
            $null = Install-Module InvokeBuild -Scope:CurrentUser
        }
        if (get-module InvokeBuild -ListAvailable) {
            Write-Output -InputObject "Importing InvokeBuild module"
            Import-Module InvokeBuild -Force
            Write-Output -InputObject '...Loaded!'
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        return $false
    }
}

function CleanUp {
    try {
        Write-Output -InputObject ''
        Write-Output -InputObject 'Attempting to clean up the session (loaded modules and such)...'
        Invoke-Build -Task BuildSessionCleanup
        Remove-Module InvokeBuild
    }
    catch {
        Write-Error "Error during cleanup - $PSItem"
    }
}

if (-not (PrerequisitesLoaded)) {
    throw 'Unable to load InvokeBuild!'
}

switch ($psCmdlet.ParameterSetName) {
    'CBH' {
        if ($AddCBH) {
            try {
                Invoke-Build -Task AddMissingCBH
            }
            catch {
                throw
            }
        }

        #CleanUp
    }
    'Build' {
        if ($NewVersion -ne $null) {
            try {
                Invoke-Build -Task UpdateVersion -NewVersion $NewVersion -ReleaseNotes $ReleaseNotes
            }
            catch {
                throw $_
            }
        }
        # If no parameters were specified or the build action was manually specified then kick off a standard build
        if (($psboundparameters.count -eq 0) -or ($BuildModule)) {
            try {
                Invoke-Build
            }
            catch {
                Write-Output -InputObject 'Build Failed with the following error:'
                Write-Output -InputObject $_
            }
        }

        # Install and test the module?
        if ($InstallAndTestModule) {
            try {
                Invoke-Build -Task InstallAndTestModule
            }
            catch {
                Write-Output -InputObject 'Install and test of module failed:'
                Write-Output -InputObject $_
            }
        }

        # Upload to gallery?
        if ($UploadPSGallery) {
            try {
                Invoke-Build -Task PublishPSGallery
            }
            catch {
                throw 'Unable to upload project to the PowerShell Gallery!'
            }
        }
        if ($AppVeyor) {
            Invoke-Build -TaskBuildInstallTestAndPublishModule
        }
        #CleanUp
    }
}