# Taken & modified from https://github.com/joefitzgerald/packer-windows
# MIT License

$ErrorActionPreference = "Stop";
if (Test-Path "a:\vagrant.pub") {
  copy a:\vagrant.pub C:\Users\vagrant\.ssh\authorized_keys
} else {
	$pubKeyUrl = "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub"
  (New-Object System.Net.WebClient).DownloadFile($pubKeyUrl, "C:\Users\vagrant\.ssh\authorized_keys")
}
