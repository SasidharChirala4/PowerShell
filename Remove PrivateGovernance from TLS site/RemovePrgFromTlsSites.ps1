#------------------------------------------------------
# This script will remove PRG library from TLS sites
# Created On: 26/06/2018
# Created By: Rakesh Laveti
# Parameters: 1.  siteUrlsCommaSeperated: Site urls of TLS Sites
#------------------------------------------------------

param(	
    [string[]]$siteUrlsCommaSeperated = "$(Read-Host 'Enter the TLS site urls comma separated. [e.g. https://edreams-a.deloitte.be/Sites/3cc9unmu/3ccagi03,https://edreams-a.deloitte.be/Sites/3cca8jyb/3ccaqg1t]')"
 )
 
#Validation
if([string]::IsNullOrEmpty($siteUrlsCommaSeperated))
{
	throw "Enter the TLS site urls comma separated, script cannot continue !!!"
}
[string]$result = "$(Read-Host 'Did you run this script with the account having Full control privileges on all inputted sites?(Y/N)')"
if ([string]::Compare($result, 'Y', $True))
{
      throw "Make sure to run this script with the account having Full control privileges on all inputted sites, script cannot continue !!!"
}


#==================== MAIN EXECUTION ====================
Write-Host ""
Write-Host "This script will remove PRG library from TLS sites."

Write-Host ""

#Function to add field to Content type
function RemovePrgLibraryFromTlsSite($siteUrl){
	try{
		 #Connect to site
		 Connect-PnPOnline $siteUrl -CurrentCredentials

		 #Remove PRG Library and quick launch menu
		 Remove-PnPList -Identity "Private Governance" -Force  
		 Remove-PnPNavigationNode -Location QuickLaunch -Title "Private governance" -Header "Documents" -Force
		 Write-Host "PRG library removed from TLS site: $($siteUrl)"
	}catch{
		Write-Host "SiteUrl - [$($siteUrl)] and ERROR - [$($_.Exception.Message)]" -foregroundcolor Red
	}
	finally{
		Disconnect-PnPOnline -ErrorAction SilentlyContinue
	}
 }

$siteUrlsCommaSeperated.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries) | ForEach {

 RemovePrgLibraryFromTlsSite $_
 
}


Write-Host ""
Write-Host "Done! This job is completed." -foregroundcolor Green

