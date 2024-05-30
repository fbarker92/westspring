# Remove all donet componants
Set-Location "C:\Program Files (x86)\dotnet-core-uninstall\"
$BaseDir = "C:\Program Files\dotnet\shared"
$Version = "8.0.0"
$Arguments = @("remove --all-below $Version --aspnet-runtime  --force --yes", 
               "remove --all-below $Version --hosting-bundle  --force --yes", 
               "remove --all-below $Version --runtime  --force --yes", 
               "remove --all-below $Version --sdk  --force --yes")

foreach ($Argument in $Arguments) {
    Write-Host "Now uninstalling  "$Argument.Substring(13)""
    Start-Process dotnet-core-uninstall.exe $Argument
}

foreach ($version in $removeSDKs) {
    if (Test-Path $BaseDir) {
        Write-Host "Cleaning up .NET SDK $version Files" 
        Get-ChildItem "C:\Program Files\dotnet\shared" -Recurse -Depth 1 | Where-Object {($_.Name -le $Version)} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}
cd "C:\Program Files (x86)\dotnet-core-uninstall\" dotnet-core-uninstall.exe remove --all-below 6.0.0 --sdk --force --yes