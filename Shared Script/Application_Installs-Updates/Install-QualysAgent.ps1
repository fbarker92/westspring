$Uri = "https://raw.githubusercontent.com/WestspringIT-Implementation/Internal_Downloads/main/Cyber%20Essentials/Qualys%20Agent/QualysCloudAgent.exe"
$DirPath =  "C:\IT\Qualys_Agent\"
$InstallerName = "Qualys_Agent.exe"
$InstallerPath = "$DirPath$InstallerName"
$ArgList = "CustomerId={{[CustomerID]}} ActivationId={{[ActivationID]}} WebServiceUri=https://qagpublic.qg2.apps.qualys.eu/CloudAgent/"

If (($null -eq $CustomerID) -or ($null -eq $ActivationID)) {
    Write-host "Please enter the CustomerID and ActivationID" -ForegroundColor Yellow
    Exit
}

# Create detination directory if it doesn't already exist
If (!(Test-Path $DirPath)) {
    Write-Host "Creating the following directory - $DirPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $DirPath -Force
}

# Download the Qualys Agent
Invoke-RestMethod -Uri $Uri -OutFile $InstallerPath
If ((Test-Path $InstallerPath)) {
    Write-Host "The fileile, $InstallerName, Successfully downloaded" -ForegroundColor Green
} else {
    Write-Host "the File download failed, please try again" -ForegroundColor Red
    Exit
}

# Install Qualys Agent
Write-Host "Installing the Qualys Agent..."
Start-Process $InstallerPath -ArgumentList $ArgList

# Clean up
Remove-Item -Path $DirPath -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path $InstallerPath)) {
    Write-Host "Installation files successfully removed"
}