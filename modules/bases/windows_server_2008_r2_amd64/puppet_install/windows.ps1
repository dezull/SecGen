<#
.SYNOPSIS
    Installs Puppet on this machine.

.DESCRIPTION
    Downloads and installs the PuppetLabs Puppet MSI package.

    This script requires administrative privileges.

    You can run this script from an old-style cmd.exe prompt using the
    following:

      powershell.exe -ExecutionPolicy Unrestricted -NoLogo -NoProfile -Command "& '.\windows.ps1'"

.PARAMETER MsiUrl
    This is the URL to the Puppet MSI file you want to install. This defaults
    to a version from PuppetLabs.

.PARAMETER PuppetVersion
    This is the version of Puppet that you want to install. If you pass this it will override the version in the MsiUrl.
    This defaults to $null.
#>
param(
   [string]$MsiUrl = "https://downloads.puppetlabs.com/windows/puppet6/puppet-agent-x64-latest.msi"
  ,[string]$PuppetVersion = $null
)

$ErrorActionPreference = "Stop";

# Puppet download requires trusted root certificates update
$rootCertsUpdateUrl = "https://download.microsoft.com/download/E/1/7/E1741061-14D6-417C-8D24-2CC83B67D342/Windows6.1-KB3004394-v2-x64.msu"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($rootCertsUpdateUrl, "C:\Windows\Temp\KB3004394.msu")
$install_args = @("C:\Windows\Temp\KB3004394.msu", "/quiet", "/norestart")
Write-Host "Updating trusted root certificates."
$process = Start-Process -FilePath wusa.exe -ArgumentList $install_args -Wait -PassThru
if ($process.ExitCode -ne 0) {
  Write-Host "Failed to updated trusted root certificates, continue anyway (exit code: $($process.ExitCode))."
}

# Previous lines will try to update the certificates after restart,
# so we need to trust the certificate for now (or in case of failure) to proceed with puppet download
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

if ($PuppetVersion) {
  $MsiUrl = "https://downloads.puppetlabs.com/windows/puppet-$($PuppetVersion).msi"
  Write-Host "Puppet version $PuppetVersion specified, updated MsiUrl to `"$MsiUrl`""
}

$PuppetInstalled = $false
try {
  Get-Command puppet | Out-Null
  $PuppetInstalled = $true
  $PuppetVersion=&puppet "--version"
  Write-Host "Puppet $PuppetVersion is installed. This process does not ensure the exact version or at least version specified, but only that puppet is installed. Exiting..."
  Exit 0
} catch {
  Write-Host "Puppet is not installed, continuing..."
}

if (!($PuppetInstalled)) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (! ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host -ForegroundColor Red "You must run this script as an administrator."
    Exit 1
  }

  Write-Host "Downloading Puppet from $MsiUrl"
  $MsiPath = "C:\Windows\Temp\puppet.msi"
  $webClient.DownloadFile($MsiUrl, $MsiPath)

  $install_args = @("/i", $MsiPath, "/qn", "/norestart")
  Write-Host "Installing Puppet. Running msiexec.exe $install_args"
  $process = Start-Process -FilePath msiexec.exe -ArgumentList $install_args -Wait -PassThru
  if ($process.ExitCode -ne 0) {
    Write-Host "Installer failed (exit code: $($process.ExitCode))."
    Exit 1
  }

  # Stop the service that it autostarts
  Write-Host "Stopping Puppet service that is running by default..."
  Start-Sleep -s 5
  Stop-Service -Name puppet

  Write-Host "Puppet successfully installed."
}
