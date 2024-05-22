# Remove all donet componants
Set-Location "C:\Program Files (x86)\dotnet-core-uninstall\"
$BaseDir = "C:\Program Files\dotnet\shared"
$Version = "{[.NET_Version_Number]}"
$Arguments = @("remove --all --aspnet-runtime  --force --yes", 
            "remove --all --hosting-bundle  --force --yes", 
            "remove --all --runtime  --force --yes", 
            "remove --all --sdk  --force --yes")

foreach ($Argument in $Arguments) {
    Write-Host "Now uninstalling  "$Argument.Substring(13)""
    Start-Process dotnet-core-uninstall.exe $Argument
}

foreach ($version in $removeSDKs) {
    if (Test-Path $installPath) {
        Write-Host "Removing .NET SDK $version at C:\Program Files\dotnet\sdk\$version" 
        Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
      }
}

C:\Program Files\dotnet\shared\Microsoft.NETCore.App\

