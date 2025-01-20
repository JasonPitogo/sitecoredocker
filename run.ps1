function LoadEnvFile {
  Get-Content .env | foreach {
    $name, $value = $_.split('=')
    if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
      continue
    }
    Set-Content env:\$name $value
  }
  
}

LoadEnvFile

#run initial Sitecore container
.\init.ps1 -LicenseXmlPath $env:LicenseXmlPath -HostName $env:HOSTNAME

#run the clean install for Sitecore docker
.\clean-install.ps1 $env:TOPOLOGY
