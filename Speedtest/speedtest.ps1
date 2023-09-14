$Uri = "https://github.com/fbarker92/westspring/raw/main/Speedtest/speedtest.exe"
$FilePath =  "C:\IT\Speedtest"
$ExePath = "C:\IT\Speedtest\speedtest.exe"
$Args = "--accept-license --accept-gdpr"

If (Test-Path $FilePath) {
    Invoke-WebRequest -Uri $Uri -OutFile $ExePath
    & $ExePath + $Args.Split(" ")
} else {
    New-Item -ItemType Directory -Path $FilePath -Force
    Invoke-WebRequest -Uri $Uri -OutFile $ExePath
    & $ExePath + $Args.Split(" ")
}

Remove-Item -Path $FilePath -Recurse