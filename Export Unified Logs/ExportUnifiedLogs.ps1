$StartDate = (Get-Date).AddDays(-365)
$EndDate = Get-Date
$PageNum = 0
$UserID = "accounts@tstcglobal.com"
$AuditOutput = @()
do {
    $PageNum = $PageNum + 1
    Write-Host "Exporting Audit Logs - Page $PageNum"
    $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -UserIds $UserID -ResultSize 5000 
    $AuditOutput | Export-Csv -Path "/Users/fergus.barker/tstc-auditlogs/logs.csv" -Append
    } while ($AuditOutput)