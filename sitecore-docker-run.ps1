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

# #run the clean install for Sitecore docker
.\clean-install.ps1 $env:TOPOLOGY

# To install the Sitecore CLI as a global tool (not recommended):
dotnet tool install Sitecore.CLI -g --add-source https://sitecore.myget.org/F/sc-packages/api/v3/index.json


#run sitecore content serialization
dotnet sitecore login --authority https://id.dockersitecore.localhost --cm https://cm.dockersitecore.localhost --allow-write true

#run sitecore content serialization push all items to sitecore instance
dotnet sitecore ser push