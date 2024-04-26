##Connect to Exchange and Msol
Connect-ExchangeOnline
Connect-MsolService

##Get list of current domains in tenant
$Domains = (Get-MsolDomain | Where-Object {$_.Name -notlike "*.onmicrosoft.com"}).Name

##Create DMARC Forensics and Aggregate shared mailboxes 
ForEach ($Domain in $Domains) {
    $Name = $Domain 
    $PrimaryEmailAddressForensics = 'DMARCForensics@' + $Domain
    $PrimaryEmailAddressAggregate = 'DMARCAggregate@' + $Domain
    
    New-Mailbox -Shared -Name "DMARC Forensics | $Name" -PrimarySmtpAddress $PrimaryEmailAddressForensics
    New-Mailbox -Shared -Name "DMARC Aggregate | $Name" -PrimarySmtpAddress $PrimaryEmailAddressAggregate
    }


##Hide DMARC Mailboxes from GAL
$DMARCMbxs = Get-Mailbox -Filter {PrimarySmtpAddress -like "DMARC*"}
ForEach ($DMARCMbx in $DMARCMbxs) {Set-Mailbox -Identity $DMARCMbx -HiddenFromAddressListsEnabled $true}

Write-Host "DKIM CNAME records..."
ForEach ($Domain in $Domains) {
    New-DkimSigningConfig -DomainName $Domain -Enabled $true -ErrorAction SilentlyContinue
    Get-DkimSigningConfig -Identity $Domain  -ErrorAction SilentlyContinue | Select Selector1CNAME,Selector2CNAME
    Write-host ""
}

Write-Host "DMARC TXT Records..."
ForEach ($Domain in $Domains) {
    Write-Host "_dmarc.$Domain" " - " "v=DMARC1; p=quarantine; pct=100; rua=mailto:DMARCAggregate@$Domain; ruf=mailto:DMARCForensics@$Domain"
    Write-Host ""
}