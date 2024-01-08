# Initialise Variables
<# $GlobalAdministrator = $null
$DirectorName = $null
$AltDirectorEmails = $null #>

# Parameter help description
Param (
    [Parameter(Mandatory = $true)][string]$GlobalAdministrator,
    [Parameter(Mandatory = $true)][string]$DirectorName,
    [Parameter(Mandatory = $true)][array]$AltDirectorEmails
)

# Check that the Global admin email is valid
If ($GlobalAdministrator -notlike "*@*.*") {
    Write-Host "Please enter a valid global administrator email" -ForegroundColor Red -BackgroundColor White
    Exit
}
ForEach ($AltDirectorEmail in $AltDirectorEmails) {
    if ($AltDirectorEmail -notlike "*@*.*") {
        Write-Host "$AltDirectorEmail is not valid, exiting" -ForegroundColor Red -BackgroundColor White
    }
}
<# $AltDirectorEmails = $AltDirectorEmails -join "," #>

# Connect to the Exchange online module
Connect-ExchangeOnline -UserPrincipalName $GlobalAdministrator

# Create the new mailflow rule with the details provided
New-TransportRule -Name "Director Phishing Rule | $DirectorName" -Mode Enforce -FromScope NotInOrganization -SenderADAttributeContainsWords "DisplayName:$DirectorName" -ExceptIfFrom $AltDirectorEmails -Quarantine $true