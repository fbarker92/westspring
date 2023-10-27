Connect-ExchangeOnline
Connect-AzureAD

$PanoCareUsers = Get-Mailbox -ResultSize Unlimited | Where-Object {($_.RecipientTypeDetails -eq "UserMailbox") -and ($_.PrimarySmtpAddress -like "*@panoramiccare*") -and ($_.PrimarySmtpAddress -notlike "*.onmicrosoft.com")}
foreach ($PanoCareUser in $PanoCareUsers){
    #Set-AzureADUser -ObjectId $PanoCareUser.PrimarySmtpAddress -CompanyName "Panoramic Care"
    Get-AzureADUser -ObjectID $PanoCareUser.PrimarySmtpAddress | Select DisplayName,CompanyName
}

$PanoAssUsers = Get-Mailbox -ResultSize Unlimited | Where-Object {()($_.RecipientTypeDetails -eq "UserMailbox") -and ($_.PrimarySmtpAddress -like "*@panoramicassociates*") -and ($_.PrimarySmtpAddress -notlike "*.onmicrosoft.com")}
foreach ($PanoAssUser in $PanoAssUsers){
    #Set-AzureADUser -ObjectId $PanoAssUser.PrimarySmtpAddress -CompanyName  "Panoramic Associates"
    Get-AzureADUser -ObjectID $PanoAssUser.PrimarySmtpAddress | Select DisplayName,CompanyName
}


$PanoDeliveryUsers = Get-AzureADUser -All $true | Where-Object {($_.JobTitle -like "*Delivery*") -and (($_.Mail -like "*@panoramicassociates*") -or ($_.Mail -like "*@panoramiccare*"))}

