#Function to Download All Files from a SharePoint Online Folder - Recursively 
Function Download-SPOFolder([Microsoft.SharePoint.Client.Folder]$Folder, $DestinationFolder)
{ 
    #Get the Folder's Site Relative URL
    $FolderURL = $Folder.ServerRelativeUrl.Substring($Folder.Context.Web.ServerRelativeUrl.Length)
    $LocalFolder = $DestinationFolder + ($FolderURL -replace "/","\")
    #Create Local Folder, if it doesn't exist
    If (!(Test-Path -Path $LocalFolder)) {
            New-Item -ItemType Directory -Path $LocalFolder | Out-Null
            Write-host -f Yellow "Created a New Folder '$LocalFolder'"
    }
    #Get all Files from the folder
    $FilesColl = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderURL -ItemType File
    #Iterate through each file and download
    Foreach($File in $FilesColl)
    {
        Get-PnPFile -ServerRelativeUrl $File.ServerRelativeUrl -Path $LocalFolder -FileName $File.Name -AsFile -force
        Write-host -f Green "`tDownloaded File from '$($File.ServerRelativeUrl)'"
    }
    #Get Subfolders of the Folder and call the function recursively
    $SubFolders = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderURL -ItemType Folder
    Foreach ($Folder in $SubFolders | Where {$_.Name -ne "Forms"})
    {
        Download-SPOFolder $Folder $DestinationFolder
    }
} 
#Set Parameters
$SiteURL = "https://bethanyschooluk.sharepoint.com/sites/10Eng2EH/SiteAssets/Forms/AllItems.aspx?FolderCTID=0x012000250A5669C2BF7C4490F63DD348CDABC5&id=%2Fsites%2F10Eng2EH%2FSiteAssets%2F10Eng2%20EH%20Notebook&viewid=83d8c3da%2D388c%2D4404%2D9ad1%2Dfef6f265137f"
$LibraryURL = "/" #Site Relative URL
$DownloadPath ="C:\it\10Eng"
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
#Get The Root folder of the Library
$Folder = Get-PnPFolder -Url $LibraryURL
#Call the function to download the document library
Download-SPOFolder $Folder $DownloadPath
 
 
#Read more: https://www.sharepointdiary.com/2017/03/sharepoint-online-download-all-files-from-document-library-using-powershell.html#ixzz8FMZPkoaM