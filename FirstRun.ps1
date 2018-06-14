# Update Chocolatey Packages
. C:\ProgramData\chocolatey\bin\choco.exe upgrade -y all

# Install Chocolatey Packages
. C:\ProgramData\chocolatey\bin\choco.exe install -y Powershell dotnet4.7 7zip.install procexp

# Remove All Users Desktop shortcut for Boxstarter
$AllUserDesktopLinks = ([environment]::GetFolderPath("CommonDesktopDirectory")) + "\*.lnk"
Get-ChildItem -Path  $AllUserDesktopLinks | Where-Object -Property Name -Like "*Boxstarter*" | Remove-Item -Force
# Remove Start Menu folder for Boxstarter
$AllUserStartMenuBoxstarter = ([environment]::GetFolderPath("CommonStartMenu")) + "\Programs\Boxstarter"
Uninstall-Directory -Path $AllUserStartMenuBoxstarter -Recurse

# Load Boxstarter Modules
Import-Module Boxstarter.Chocolatey
Import-Module Boxstarter.WinConfig

# Turn on Microsoft Update
Enable-MicrosoftUpdate

# Disable User Account Control
Disable-UAC

# Enable Remote Desktop
Enable-RemoteDesktop

# Set Powershell Execution to RemoteSigned
Update-ExecutionPolicy -policy RemoteSigned

# Enable Remote Management
Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Create some RMM settings ahead of time to cut down on reboots
# Event source to create
$RMMEventSource = "VisionIT"

# List of folders to check for and create the folders if they don't exist
$RMMBase = $env:SystemDrive + "\" + $RMMEventSource + "_MSP"
$ErrorPath = $RMMBase + "\Errors"
$LogPath = $RMMBase + "\Logs"
$ReportPath = $RMMBase + "\Reports"
$StagingPath = $RMMBase + "\Staging"
$AllFolders = $RMMBase,$ErrorPath,$LogPath,$ReportPath,$StagingPath

# Create Folders
foreach ($item in $AllFolders) {
    Install-Directory -Path $item
}

# Make sure the base RMM folder is hidden
Get-Item -Path $RMMBase -Force | ForEach-Object {$_.Attributes = $_.Attributes -bor "Hidden"}

# Create Event Source
[System.Diagnostics.EventLog]::CreateEventSource( $RMMEventSource, "Application" )

# Environment Variables
Set-EnvironmentVariable -Name 'RMMFolder' -Value $RMMBase -ForComputer -Force
et-EnvironmentVariable -Name 'RMMErrorFolder' -Value $ErrorPath -ForComputer -Force