$Uri = "https://videolan.mirrors.nublue.co.uk/vlc/3.0.18/win64/vlc-3.0.18-win64.msi"
$FilePath =  "C:\IT\VLC\"
$MSIName = "VLC.msi"
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
msiexec.exe /i $MSIPath /qn /norestart

Start-Sleep -Seconds 60

# Clean up
Remove-Item -Path $FilePath -Recurse -ErrorAction SilentlyContinue
