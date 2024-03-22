# Initialise vars
$Uri = "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-700.exe"
$OutPath =  "C:\IT\winrar\"
$OutName = "winrar-x64-700.exe"
$OutFile = "$OutPath$OutName"
$isLocked = $true
$RegTest = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\winrar.exe'

# Check registry if chrome keys are present
if($RegTest -eq $false){
   Write-Host "Application is not installed, exiting..."
   exit 0
}else{
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
        Start-Sleep -Seconds 5
    }
}


# Install Chrome .msi
Start-Process -FilePath $OutFile -ArgumentList "/S" -Wait

# Pause script while install is in progress
Start-Sleep -Seconds 300

# Clean up
Remove-Item -Path $OutFile -Recurse -ErrorAction SilentlyContinue
}


