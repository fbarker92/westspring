function Ensure-ExchangeOnlineManagementModule {
    <#
    .SYNOPSIS
    Ensures that the ExchangeOnlineManagement module is installed.

    .DESCRIPTION
    This function checks if the ExchangeOnlineManagement module is installed. If it's not installed, the function will attempt to install it from the PowerShell Gallery.

    .EXAMPLE
    Ensure-ExchangeOnlineManagementModule

    .NOTES
    This function requires administrative privileges to install the module from the PowerShell Gallery.
    #>

    $moduleName = "ExchangeOnlineManagement"
    $installedModule = Get-Module -ListAvailable -Name $moduleName

    if ($null -eq $installedModule) {
        Write-Host "The $moduleName module is not installed. Installing it now..."

        try {
            Install-Module -Name $moduleName -Force -Scope CurrentUser
            Write-Host "The $moduleName module has been installed successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install the $moduleName module: $_"
        }
    }
    else {
        Write-Host "The $moduleName module is already installed." -ForegroundColor Green
    }
}
function Ensure-MicrosoftGraphModule {
    <#
    .SYNOPSIS
    Ensures that the Microsoft.Graph module is installed.

    .DESCRIPTION
    This function checks if the Microsoft.Graph module is installed. If it's not installed, the function will attempt to install it from the PowerShell Gallery.

    .EXAMPLE
    Ensure-MicrosoftGraphModule

    .NOTES
    This function requires administrative privileges to install the module from the PowerShell Gallery.
    #>

    $moduleName = "Microsoft.Graph"
    $installedModule = Get-Module -ListAvailable -Name $moduleName

    if ($null -eq $installedModule) {
        Write-Host "The $moduleName module is not installed. Installing it now..."

        try {
            Install-Module -Name $moduleName -Force -Scope CurrentUser
            Write-Host "The $moduleName module has been installed successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install the $moduleName module: $_"
        }
    }
    else {
        Write-Host "The $moduleName module is already installed." -ForegroundColor Green
    }
}

function Get-M365Domains {
    <#
    .SYNOPSIS
    Retrieves all domains associated with the Microsoft 365 tenant.

    .DESCRIPTION
    This function uses the Microsoft Graph API to retrieve a list of all domains associated with the Microsoft 365 tenant.
    It requires authentication with the Microsoft Graph API using an access token.

    .EXAMPLE
    Get-M365Domains

    .NOTES
    Before running this function, you need to install the Microsoft.Graph module and authenticate with the Microsoft Graph API.
    You can install the module using the following command:

    Install-Module Microsoft.Graph -Scope CurrentUser

    For authentication, you can use the Connect-MgGraph cmdlet or follow the instructions in the Microsoft Graph documentation.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/resources/domain
    #>
    $tenantDomains = $null
    Disconnect-MgGraph
    try {
        # Connect the Microsoft Graph module with the "Domain.Read.All" scope
        Connect-MgGraph -Scopes "Domain.Read.All" -NoWelcome

        # Get all domains from the Microsoft Graph API
        $tenantDomains = Get-MgDomain -All | Where-Object { $_.Id -notlike "*.onmicrosoft.com" }

        # Return the domains
        return $tenantDomains
    }
    catch {
        Write-Error "Error retrieving domains: $_"
    }
}

function Select-Domain {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Domains
    )

    if ($Domains) {
        Write-Host "Available domains:"
        $Domains | ForEach-Object { Write-Host "[$($Domains.IndexOf($_) + 1)] $_" }
        Write-Host "[$($Domains.Count + 1)] All Domains"

        $selection = Read-Host "Enter the number of the domain(s) you want to proceed with"
        if ($selection -gt 0 -and $selection -le $Domains.Count) {
            $selectedDomains = $Domains[$selection - 1]
            Write-Host "You selected: $selectedDomains" -ForegroundColor Green
            return $selectedDomains
        }
        elseif ($selection -eq ($Domains.Count + 1)) {
            $selectedDomains = $Domains
            Write-Host "You selected all domains." -ForegroundColor Green
            return $selectedDomains
        }
        else {
            Write-Host "Invalid selection. Exiting."
            return
        }
    }
    else {
        Write-Host "No custom domains found."
        return
    }
}
function New-DMARCMailboxes {
    <#
    .SYNOPSIS
    Creates DMARC Forensics and Aggregate mailboxes for specified domains.

    .DESCRIPTION
    This function creates two shared mailboxes for each specified domain:
    1. DMARC Forensics mailbox
    2. DMARC Aggregate mailbox

    If an error occurs during mailbox creation, the error is logged to a file named "MailboxCreationErrors.log" in the current working directory.

    .PARAMETER SelectedDomains
    An array of domain names for which the DMARC mailboxes should be created.

    .EXAMPLE
    New-DMARCMailboxes -SelectedDomains @("contoso.com", "fabrikam.com")

    .NOTES
    This function requires the ExchangeOnlineManagement module to be installed and connected to Exchange Online.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$SelectedDomains
    )

    process {
        foreach ($selectedDomain in $SelectedDomains) {
            $Name = $selectedDomain
            $PrimaryEmailAddressForensics = "DMARCForensics@$selectedDomain"
            $PrimaryEmailAddressAggregate = "DMARCAggregate@$selectedDomain"

            try {
                $ForensicsMailbox = New-Mailbox -Shared -Name "DMARC Forensics | $Name" -PrimarySmtpAddress $PrimaryEmailAddressForensics -ErrorAction Stop
                Write-Host "Created mailbox: $($ForensicsMailbox.PrimarySmtpAddress)" -ForegroundColor Green

                $AggregateMailbox = New-Mailbox -Shared -Name "DMARC Aggregate | $Name" -PrimarySmtpAddress $PrimaryEmailAddressAggregate -ErrorAction Stop
                Write-Host "Created mailbox: $($AggregateMailbox.PrimarySmtpAddress)" -ForegroundColor Green
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "An error occurred while creating mailboxes for $($selectedDomain):" -ForegroundColor Red
                Write-Host $ErrorMessage -ForegroundColor Yellow

                # Log the error to a file
                $LogFilePath = Join-Path -Path $PWD.Path -ChildPath "MailboxCreationErrors.log"
                $LogEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error creating mailboxes for $($selectedDomain): $ErrorMessage"
                Add-Content -Path $LogFilePath -Value $LogEntry
            }
        }
    }
}

function Get-DKIMSigningConfig {
    <#
    .SYNOPSIS
    Retrieves and configures DKIM signing configurations for specified domains.

    .DESCRIPTION
    This function retrieves the DKIM signing configuration for each specified domain. If the configuration is not enabled, it enables the DKIM signing configuration for the domain. If the configuration is already enabled, it displays the CNAME records for the selectors.

    .PARAMETER SelectedDomains
    An array of domain names for which the DKIM signing configuration should be retrieved and configured.

    .EXAMPLE
    Get-DKIMSigningConfig -SelectedDomains @("contoso.com", "fabrikam.com")

    .NOTES
    This function requires the ExchangeOnlineManagement module to be installed and connected to Exchange Online.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$SelectedDomains
    )

    process {
        Write-Host "DKIM CNAME records..."

        foreach ($selectedDomain in $SelectedDomains) {
            Write-Host $selectedDomain -ForegroundColor Green
            $DKIMRecord = Get-DkimSigningConfig -Identity $selectedDomain -ErrorAction SilentlyContinue | Select-Object Enabled, Selector1CNAME, Selector2CNAME

            if ($DKIMRecord.Enabled -eq $false) {
                New-DkimSigningConfig -DomainName $selectedDomain -Enabled $true -ErrorAction SilentlyContinue
            }
            else {
                Write-Host $DKIMRecord.Selector1CNAME
                Write-Host $DKIMRecord.Selector2CNAME
            }

            Write-Host ""
        }
    }
}

function Get-DMARCTXTRecords {
    <#
    .SYNOPSIS
    Displays the DMARC TXT records for specified domains.

    .DESCRIPTION
    This function displays the DMARC TXT records for each specified domain. The TXT records include the DMARC policy, percentage, aggregate reporting mailbox, and forensic reporting mailbox.

    .PARAMETER SelectedDomains
    An array of domain names for which the DMARC TXT records should be displayed.

    .EXAMPLE
    Get-DMARCTXTRecords -SelectedDomains @("contoso.com", "fabrikam.com")

    .NOTES
    This function assumes that the DMARC Aggregate and DMARC Forensics mailboxes have been created for the specified domains.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$SelectedDomains
    )

    process {
        Write-Host "DMARC TXT Records..."

        foreach ($selectedDomain in $SelectedDomains) {
            Write-Host $selectedDomain -ForegroundColor Green
            $dmarcTxtRecord = "_dmarc.$selectedDomain" + " - " + "v=DMARC1; p=quarantine; pct=100; rua=mailto:DMARCAggregate@$selectedDomain; ruf=mailto:DMARCForensics@$selectedDomain; fo=0"
            Write-Host $dmarcTxtRecord
            Write-Host ""
        }
    }
}

Ensure-ExchangeOnlineManagementModule
Ensure-MicrosoftGraphModule
Get-M365Domains
$selectedDomains = Select-Domain -Domains $tenantDomains.Id
New-DMARCMailboxes -SelectedDomains $selectedDomains
Get-DKIMSigningConfig -SelectedDomains $selectedDomains
Get-DMARCTXTRecords -SelectedDomains $selectedDomains
Write-Host "Press any key to exit..."
Read-Host