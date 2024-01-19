# Remove all donet componants
CD "C:\Program Files (x86)\dotnet-core-uninstall\"
$Arg1 = "remove --all --aspnet-runtime  --force --yes"
$Arg2 = "remove --all --hosting-bundle  --force --yes"
$Arg3 = "remove --all --runtime  --force --yes"
$Arg4 = "remove --all --sdk  --force --yes"

Start-Process dotnet-core-uninstall.exe $Arg1
Start-Process dotnet-core-uninstall.exe $Arg2
Start-Process dotnet-core-uninstall.exe $Arg3
Start-Process dotnet-core-uninstall.exe $Arg4

