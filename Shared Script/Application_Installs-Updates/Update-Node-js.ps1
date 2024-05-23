$CurrVers = node -v
Write-Host "The current Node.JS version is $CurrVers"
Write-Host "Checking and installing any updates..."
npm install -g npm-windows-upgrade
npm-windows-upgrade
$NewVers = node -v
Write-Host "Node.JS is now on $CurrVers"