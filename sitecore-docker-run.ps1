function LoadEnvFile {
  Get-Content .env | ForEach-Object {
    $name, $value = $_.split('=')
    if (![string]::IsNullOrWhiteSpace($name) -and !$name.Contains('#')) {
      Set-Content env:\$name $value
    }
  }
}

LoadEnvFile

# Define the folder name relative to the current directory
$folderName = "/docker/data/cd"

# Get the full path to the folder
$folderPath = Join-Path -Path (Get-Location) -ChildPath $folderName

# Check if the folder exists
if (Test-Path -Path $folderPath) {
    # Get the list of files and subfolders in the folder
    $items = Get-ChildItem -Path $folderPath

    # Check if the folder is empty
    if ($items.Count -eq 1 -or $args -contains '-force') {
      Write-Output "Initialize Sitecore Container"
      # Run initial Sitecore container
      .\init.ps1 -LicenseXmlPath $env:LicenseXmlPath -HostName $env:HOSTNAME
      Write-Output "Run Clean Install for Sitecore Docker"
      # Run the clean install for Sitecore docker
      .\clean-install.ps1 $env:TOPOLOGY
    }
    Write-Output "Installing Sitecore CLI"
    # To install the Sitecore CLI as a global tool (not recommended):
    dotnet tool install Sitecore.CLI -g --add-source https://sitecore.myget.org/F/sc-packages/api/v3/index.json
    
    Write-Output "Logging in to Sitecore instance for Content Serialization"
    # Run Sitecore content serialization
    dotnet sitecore login --authority https://id.dockersitecore.localhost --cm https://cm.dockersitecore.localhost --allow-write true

    Write-Output "Pushing Sitecore content serialization"
    # Run Sitecore content serialization push all items to Sitecore instance
    dotnet sitecore ser push
} else {
    Write-Output "The folder does not exist."
}
