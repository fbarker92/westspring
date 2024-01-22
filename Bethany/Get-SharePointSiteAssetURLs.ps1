#Set Variables
Param (
[string] $SiteURL=$(Read-Host -prompt "Enter the full site URL")
)

# Check PowerShell version that script is being run in
if ([int]$PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7 or newer in order to run - https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4&viewFallbackFrom=powershell-7&WT.mc_id=THOMASMAURER-blog-thmaure"
    Read-Host "Press any key to continue"
}
$ListName= "Site Assets"
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get All Files from the document library - In batches of 500
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 | Where-Object {$_.FileSystemObjectType -eq "Folder"}
  
#Loop through all documents
$DocumentsData=@()
ForEach($Item in $ListItems)
{
    #Collect Documents Data
    $DocumentsData += New-Object PSObject -Property @{
    FileName = $Item.FieldValues['FileLeafRef']
    FileURL = $Item.FieldValues['FileRef']
    }
}
#sharepoint online get all files in document library powershell
$DocumentsData
