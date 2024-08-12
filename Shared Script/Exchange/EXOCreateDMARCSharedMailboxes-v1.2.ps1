##Connect to Exchange and Msol
Connect-ExchangeOnline
Connect-MsolService

##Get list of current domains in tenant
$Domains = $null
$MsolDomains = Get-MsolDomain
if ($MsolDomains) {
    $Domains = ($MsolDomains | Where-Object { $_.Name -notlike "*.onmicrosoft.com" }).Name
}

if ($Domains) {
    Write-Host "Available domains:"
    $Domains | ForEach-Object { Write-Host "[$($Domains.IndexOf($_) + 1)] $_" }
    Write-Host "[$($Domains.Count + 1)] All Domains"

    $selection = Read-Host "Enter the number of the domain(s) you want to proceed with"
    if ($selection -gt 0 -and $selection -le $Domains.Count) {
        $selectedDomains = $Domains[$selection - 1]
        Write-Host "You selected: $selectedDomains"
        # Proceed with the selected domain
    }
    elseif ($selection -eq ($Domains.Count + 1)) {
        $selectedDomains = $Domains
        Write-Host "You selected all domains."
        # Proceed with all domains
    }
    else {
        Write-Host "Invalid selection. Exiting."
    }
}
else {
    Write-Host "No custom domains found."
}

##Create DMARC Forensics and Aggregate shared mailboxes 
Write-Host "Creating DMARC Shared Mailboxes..."
ForEach ($selectedDomain in $selectedDomains) {
    $Name = $selectedDomain
    $PrimaryEmailAddressForensics = "DMARCForensics@" + $selectedDomain
    $PrimaryEmailAddressAggregate = "DMARCAggregate@" + $selectedDomain

    try {
        $ForensicsMailbox = New-Mailbox -Shared -Name "DMARC Forensics | $Name" -PrimarySmtpAddress $PrimaryEmailAddressForensics -ErrorAction Stop
        Write-Host "Created mailbox: $($ForensicsMailbox.PrimarySmtpAddress)" -ForegroundColor Green

        $AggregateMailbox = New-Mailbox -Shared -Name "DMARC Aggregate | $Name" -PrimarySmtpAddress $PrimaryEmailAddressAggregate -ErrorAction Stop
        Write-Host "Created mailbox: $($AggregateMailbox.PrimarySmtpAddress)" -ForegroundColor Green
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "An error occurred while creating mailboxes for $($Domain):" -ForegroundColor Red
        Write-Host $ErrorMessage -ForegroundColor Yellow

        # Log the error to a file
        $LogFilePath = Join-Path -Path $PWD.Path -ChildPath "MailboxCreationErrors.log"
        $LogEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error creating mailboxes for $($Domain): $ErrorMessage"
        Add-Content -Path $LogFilePath -Value $LogEntry
    }
}

Write-Host "DKIM CNAME records..."
ForEach ($selectedDomain in $selectedDomains) {
    Write-Host $selectedDomain -ForegroundColor Green
    $DKIMRecord = Get-DkimSigningConfig -Identity $selectedDomain -ErrorAction SilentlyContinue | Select Enabled,Selector1CNAME,Selector2CNAME
    If ($DKIMRecord.Enabled -eq $false) {
        New-DkimSigningConfig -DomainName $selectedDomain -Enabled $true -ErrorAction SilentlyContinue
    } else{
        Write-host $DKIMRecord.Selector1CNAME
        Write-Host $DKIMRecord.Selector2CNAME
    }
Write-host ""
}

Write-Host "DMARC TXT Records..."
ForEach ($selectedDomain in $selectedDomains) {
    Write-Host $selectedDomain -ForegroundColor Green
    Write-Host "_dmarc.$selectedDomain" " - " "v=DMARC1; p=quarantine; pct=100; rua=mailto:DMARCAggregate@$selectedDomain; ruf=mailto:DMARCForensics@$selectedDomain; fo=0"
    Write-Host ""
}

Write-Host "Press any key to exit..."
Read-Host