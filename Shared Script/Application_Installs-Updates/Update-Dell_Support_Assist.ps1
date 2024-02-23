$Uri = "https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe"
$FilePath =  "C:\IT\Dell\"
$MSIName = "Dell_Support_Assist.exe"
$MSIPath = "$FilePath$MSIName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $MSIPath
Do {
    Start-Sleep -Seconds 5
    $downloadStatus = Get-Item $MSIPath
} While ($downloadStatus.Length -lt $downloadStatus.Length)


# Install .msi
Start-Process -FilePath $MSIPath -ArgumentList "/Silent" -Wait

Start-Sleep -Seconds 60

# Clean up
Remove-Item -Path $FilePath -Recurse -ErrorAction SilentlyContinue
