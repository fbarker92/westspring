# Disable Internet Explorer OOBE
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2

# Downloads and saves the Rule XML template
$Uri = 'https://raw.githubusercontent.com/fbarker92/westspring/main/Phished%20Deployment/PhishedMailfloWRulesTemplate.xml'
$xmlDownload = Invoke-WebRequest -ContentType 'application/xml' -Uri $Uri

# Set variables
$365GA = Read-Host "Enter the UPN for a Global Administrator"
$PhishedIPs = '143.55.236.228','143.55.236.227','143.140.69.192','34.140.69.192','34.22.133.124'
$ConnectionFilterPolicyIPs = '34.22.133.124','34.140.69.192','143.55.236.247','143.55.236.228','143.55.236.227'
$PhishedDomains = 'psr.phished.io','phished.io'
$ClientSecurityHeader = Read-Host "Enter the Client Security Header (Found in the phished portal)"

#Import Exchange Online Management Module
Import-Module ExchangeOnlineManagement

#Connect to the Exchange Online Management Module 
Connect-IPPSSession -UserPrincipalName $365GA

# Check if there is a pre-existing PhishSimOverridePolicy to use, will create one if not
If ((Get-PhishSimOverrideRule).Name.count -ne 0) {
    Write-Host "A Phising Override Rule already exists ($((Get-PhishSimOverrideRule).Name)), adding the Phished Domains and IPs"
    Get-PhishSimOverrideRule | Set-PhishSimOverrideRule -AddDomains $PhishedDomains -AddSenderIpRanges $PhishedIPs
} elseif (((Get-PhishSimOverridePolicy).Name.Count -ne 0) -and ((Get-PhishSimOverrideRule).Name.Count -eq 0)) {
    Write-Host "A Phishing Override Policy exists ($((Get-PhishSimOverridePolicy).Name)), but there isn't a rule. Creating the rule 'Phished'"
    $PolicyName = Get-PhishSimOverridePolicy
    New-PhishSimOverrideRule -Name 'Phished' -Policy $PolicyName.Name -Domains $PhishedDomains -SenderIpRanges $PhishedIPs
} else {
    Write-Host "There is no Policy or Rule, creating a Policy (PhishedOverridePolicy), and Rule (Phished)"
    New-PhishSimOverridePolicy -Name 'PhishedOverridePolicy'
    New-PhishSimOverrideRule -Name 'Phished' -Policy PhishedOverrideRule -Domains $PhishedDomains -SenderIpRanges $PhishedIPs
} 
    
Start-Sleep 2

# Connect to the Exchagne Online module
Connect-ExchangeOnline

# Set the Default Connection Filter policy to Enabled and set the IP ALlow list
Write-Host "Adding the Phished IP addresses to the Default Connection Filter Policy"
Set-HostedConnectionFilterPolicy -Identity Default -EnableSafeList $true -IPAllowList $ConnectionFilterPolicyIPs
Start-Sleep 2

# Import the Mailflow rules
[xml]$xml = $xmlDownload.Content.tostring().Replace('*ClientSecurityHeader*', $ClientSecurityHeader)
$rulesToImport = $xml.SelectNodes("//rules/rule")
if ($rulesToImport.Count -eq 0)
{
    Write-Host "There are no mail flow rules to be imported."
    return
}
Write-Host "Importing $($rulesToImport.Count) mail flow rules."
$index = 0
foreach ($rule in $rulesToImport)
{
    $index++
    Write-Host "Importing rule '$($rule.Name)' $index/$($rulesToImport.Count)."
    Invoke-Expression $($rule.version.commandBlock.InnerText) | Out-Null
}
