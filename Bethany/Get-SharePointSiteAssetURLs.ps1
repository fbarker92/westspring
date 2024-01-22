#Set Variables
Param (
[string] $SiteURL=$(Read-Host -prompt "Enter the full site URL")
)
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
