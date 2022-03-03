#------------------------------------------------------
# This script will update Private Governance library name to PRG Advisory & Rename Contenttypes
# Created On: 15/09/2020
# Updated On: 21/10/2020
# Created By: Sasidhar
# Parameters: 1.  siteUrlsFile: File path of siteCollection urls of PRG Sites
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteUrlsFile,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)


$ListName = "Private governance"
$NewListURL = "PRG Advisory"
$DummyListURL = "PRG Advisory1"
$DocContentTypeName = "FIDU - PRG - Private governance Document"
$NewDocContentTypeName = "FIDU - PRG - Private Advisory Document"
$MailContentTypeName = "FIDU - PRG - Private governance Mail"
$NewMailContentTypeName = "FIDU - PRG - Private Advisory Mail"

# Change Library Url
function ChangeLibraryUrl([string]$siteUrl)
{  
    try{
       # Connect to PNP Online
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $siteUrl -CurrentCredentials
		$context = Get-PnPContext
		
		# Get the List
	    $list= Get-PnPList -Identity $ListName -Includes RootFolder
		if($list -ne $null){
			# Sharepoint online powershell change list url
			$list.Rootfolder.MoveTo($NewListURL)
			Invoke-PnPQuery
			$message = "Change library url is completed for site: " + $siteUrl
			LogWrite $message		
		}
		
		# Rename & Revert List to set ManagedMetadata navigation properly
	    Set-PnPList -Identity $NewListURL -Title $DummyListURL
		Set-PnPList -Identity $DummyListURL -Title $NewListURL 
	    $message = "Updated ManagedMetadata Navigation for site: " + $siteUrl
	    LogWrite $message
		
		# Change Document ContentType Name
	    $docContentType = Get-PnPContentType -List $NewListURL | Where {$_.Name -eq $DocContentTypeName}
		if($docContentType -ne $null){
			$docContentType.Name= $NewDocContentTypeName
			$docContentType.Update($false)
			$context.Load($docContentType)
		}
	
	    # Change Mail ContentType Name
	    $mailContentType = Get-PnPContentType -List $NewListURL | Where {$_.Name -eq $MailContentTypeName}
	    if($mailContentType -ne $null){
			$mailContentType.Name= $NewMailContentTypeName
			$mailContentType.Update($false)
			$context.Load($mailContentType)
		}
	    $context.ExecuteQuery()
	    $message = "Change contenttype name is completed for site: " + $siteUrl
	    LogWrite $message
		
    }
    catch{
		$message = "Error at site level for url: " + $siteUrl +" is: " + $error
        LogWrite $message
    }
    finally{
        # Disconnect
        Disconnect-PnPOnline
    }
}

# Log info to a local file
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $logFile -value $logstring
}

# Main Call
Write-Host 'Process started'

Get-Content $siteUrlsFile | ForEach-Object {
    # Update Locale value fro all webs
    ChangeLibraryUrl($_.Trim()) 
}

Write-Host 'Process completed'
