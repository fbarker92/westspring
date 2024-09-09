# Check if required module is installed
$modulePresent = Get-Module -Name Microsoft.Graph.Teams -ListAvailable
If (!($modulePresent)) {
    Write-Host "Microsoft.Graph.Teams module not found. Now attempting to install..."
    Install-Module -Name Microsoft.Graph.Teams -Scope CurrentUser -Force
}
# Connect to the Graph with the necessary permissions
Connect-MgGraph -Scopes Chat.ReadWrite, Chat.ManageDeletion.All -NoWelcome
 # Find the object identifier for the signed-in user
$Account = (Get-MgContext).Account
$UserId = (Get-MgUser -UserId $Account).Id

# Get chats for the user
[array]$Chats = Get-MgUserChat -Userid $UserId -All -Filter "chattype eq 'oneonone'" | Sort-Object LastUpdatedDateTime -Descending

# Extract the identifiers for the tenants that chat threads belong to so that we can resolve them to a tenant name
Write-Host "Finding tenant information for chats..."
$TenantList = [System.Collections.Generic.List[Object]]::new()
ForEach ($Chat in $Chats) {
   $TenantList.Add($Chat.TenantId)
}
<# 
$TenantsCount = @{}
$TenantList = $TenantList | Sort-Object
$TenantList | ForEach-Object {$TenantsCount[$_]++}
$TenantsCount = $TenantsCount.GetEnumerator() | Sort-Object -Property Value -Descending
$TenantsCount

# Now build a hash table of tenant identifiers and names that we can use to look up tenants
Write-Host "Resolving tenant identifiers..."
$TenantsHash = @{}
ForEach ($Tenant in $TenantsCount) {
    $Uri = ("https://graph.microsoft.com/V1.0/tenantRelationships/findTenantInformationByTenantId(tenantId='{0}')" -f $Tenant.Name.ToString())
    $ExternalTenantData = Invoke-MgGraphRequest -Uri $Uri -Method Get -SkipHttpErrorCheck
    $TenantsHash.Add([string]$Tenant.Name.toString(), [string]$ExternalTenantData.displayName)
} #>

# Create output report
$Report = [System.Collections.Generic.List[Object]]::new()

# Extract information for each chat thread and write it out to the report file
Write-Host "Analyzing chat threads..."
ForEach($Chat in $Chats) {
    # Get members of the chat thread
    [array]$Members = Get-MgUserChatMember -UserId $UserId -ChatId $Chat.Id

    # Extract the member display names and remove any blanks (accounts that no longer exist)
    [array]$MemberNames = $Members.displayName | Sort-Object -Unique
    $NumberOfParticipants = $MemberNames.Count
    If ($MemberNames.Count -gt 0) {
        $MemberNamesOutput = $MemberNames -Join ", "
    }

<#     # Get tenant display name
    $TenantDisplayName = "Unknown"
    $TenantDisplayName = $TenantsHash[$Chat.TenantId] #>

    $ReportLine = [PSCustomObject][Ordered]@{
      ChatType             = $Chat.ChatType
      Topic                = $Chat.Topic
      Created              = $Chat.CreatedDateTime
      LastUpdated          = $Chat.LastUpdatedDateTime
      NumberOfParticipants = $NumberOfParticipants
      Participants         = $MemberNamesOutput
      TenantId             = $Chat.TenantId
      Tenant               = $TenantDisplayName
      Id                   = $Chat.Id
      WebUrl               = $Chat.WebUrl }     
    $Report.Add($ReportLine) 
} # End ForEach chats

#$Report | Select-Object ChatType, Topic, Created, LastUpdated, NumberOfParticipants, Participants, Tenant, Id | Sort-Object LastUpdated -Descending | Out-GridView -passThru

# Import the excluded participants from a CSV file
# This will prevent the script from deleting chats that contain the excluded participants
$excludedParticipants = @('Danny Mathews','Liz Painter')  #Import-Csv -Path "path\to\your\file.csv" | Select-Object -ExpandProperty ParticipantName

# Check if the chat participants are in the excluded list
$ChatIdsToDelete = @()
foreach ($Item in $Report){
    $chatParticipants = $Item.Participants.Split(",").Trim()
    $shouldDelete = $true
    foreach ($participant in $chatParticipants) {
        if ($excludedParticipants -contains $participant) {
            $shouldDelete = $false
            break
        }
    }
    if ($shouldDelete) {
        Write-Host "Chat Id: $($Item.Id)"
        Write-Host "Chat Participants: $($Item.Participants)"
        $ChatIdsToDelete += $Item
    }
}
ForEach ($Item in $ChatIdsToDelete){
    Remove-MgChat -ChatId $Item.Id
    Write-Host "Chat $($Item.Id) deleted"
    $deltedChatId = Get-MgTeamworkDeletedChat -DeletedChatId $($Item.Id) | Select-Object -ExpandProperty Id
    Remove-MgBetaTeamworkDeletedChat -DeletedChatId $deltedChatId
    Write-Host "Deleted Chat $deltedChatId deleted"
} 
