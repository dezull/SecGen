$ErrorActionPreference = "Stop";
$builder = $Env:PACKER_BUILDER_TYPE
$wc = New-Object System.Net.WebClient

Write-Host "$builder guest tools to be installed."
if ($builder -eq "vmware-iso") {
  $toolsUrl = "https://packages.vmware.com/tools/esx/6.7latest/windows/x64/VMware-tools-10.3.2-9925305-x86_64.exe"
  $toolsPath = "C:\Windows\Temp\VMware-tools.exe"

  Write-Host "Downloading VMware tools from $toolsUrl."
  $wc.DownloadFile($toolsUrl, $toolsPath)
  Write-Host "Installing VMware tools."
  $install_args = @("/S", "/l", "C:\Windows\Temp\vmware-install.log", '/v "/qn REBOOT=R"')
  $process = Start-Process -FilePath $toolsPath -ArgumentList $install_args -Wait -PassThru

  if (($process.ExitCode -ne 0) -and ($process.ExitCode -ne 3010)) {
      Write-Host "Failed to install VMware tools. (exit code: $($process.ExitCode))"
      exit 1
  }
} elseif ($builder -eq "virtualbox-iso") {
  Write-Host "Installing VirtualBox guest additions"
  $installerPath = "C:\Windows\Temp\virtualbox"

  mkdir -Force "$installerPath"

  Get-ChildItem E:/cert/ -Filter vbox*.cer | ForEach-Object {
    E:/cert/VBoxCertUtil.exe add-trusted-publisher $_.FullName --root $_.FullName
  }

  Start-Process -FilePath "E:/VBoxWindowsAdditions.exe" -ArgumentList "/S" -WorkingDirectory "$installerPath" -Wait
  if ($process.ExitCode -ne 0) {
      Write-Host "Failed to install VirtualBox guest additions. (exit code: $($process.ExitCode))"
      exit 1
  }
} else {
  Write-Host "Unknown platform '$builder'"
}

Write-Host "Self delete this script"
Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
