# Remove all donet componants
Set-Location "C:\Program Files (x86)\dotnet-core-uninstall\"
$DNUTBaseDir = "C:\Program Files\dotnet\shared"
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
    if (Test-Path $DNUTBaseDir) {
        Write-Host "Cleaning up .NET SDK $version Files" 
        Get-ChildItem "C:\Program Files\dotnet\shared" -Recurse -Depth 1 | Where-Object {($_.Name -le $Version)} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}
<<<<<<< HEAD

=======
>>>>>>> ee000efdae223344ec055670c609f80b7c8e870b
