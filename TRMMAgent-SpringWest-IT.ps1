# Define the URI and the destination path
$uri = 'https://api.springwest.co.uk/clients/4b03ef7f-d251-441d-9322-ab9442cf21a3/deploy/'
$logDirectory = 'C:\IT\Intune\Logs'
$logFile = "$logDirectory\TRMMAgent.log"
$destination = "$env:TEMP\TRMMAgent.exe"

# Create the log directory if it doesn't exist
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory -Force
}

# Download the file
Invoke-WebRequest -Uri $uri -OutFile $destination

# Execute the file with arguments and redirect output to log file
Start-Process -FilePath $destination -ArgumentList '--silent' -RedirectStandardOutput $logFile -RedirectStandardError $logFile -Wait

# Check if the process executed successfully
if ($LASTEXITCODE -eq 0) {
    # Remove the downloaded file
    Remove-Item -Path $destination -Force
} else {
    Write-Error "The process did not complete successfully. Check the log file at $logFile for more details."
}