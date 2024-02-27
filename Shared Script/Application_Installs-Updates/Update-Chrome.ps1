$Uri = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
$OutPath =  "C:\IT\Google_Chrome\"
$OutName = "google-chrome.msi"
$OutFile = "$OutPath$OutName"
$isLocked = $true

# Create detination directory if it doesn't already exist
If (!(Test-Path $OutPath)) {
    New-Item -ItemType Directory -Path $OutPath -Force
}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $OutFile

while ($isLocked) {
    Try {
        $stream = [System.IO.File]::Open($OutFile, 'Open', 'Write')
        $stream.Close()
        $stream.Dispose()
        $isLocked = $false
    }
    catch {
        Start-Sleep -Seconds 30
    }
}


# Install Chrome .msi
msiexec.exe /i $OutFile /qn /norestart

Start-Sleep -Seconds 300
# Clean up
Remove-Item -Path $OutFile -Recurse -ErrorAction SilentlyContinue
