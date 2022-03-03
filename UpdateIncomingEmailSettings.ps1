################################################
# This script will Enable Incoming E-mail settings on the library
# And set properties for it
#Parameters:
#  SiteUrl - Site on which the Incoming E-mail settings
#  ListName - Title of the library on which the Incoming E-mail settings needs to be enabled
#  EmailAlias - Email Address that needs to be set for Incoming Emails, example:test123 (@deloitte.com(suffix) is set by default by Library)
#				There should not be any space in EmailAlias, 
# Created: [Ramya Reddy - 25/09/2019]
################################################
param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$SiteUrl, 

    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$ListName,
    
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$EmailAlias
)


#  Load Snapins
Try
{
	@('Microsoft.SharePoint.PowerShell') | % {
		   $snapinName = $_
		   if ((Get-PSSnapin | ? {$_.Name -eq $snapinName}) -eq $null)
		   {
				  Write-Host "Adding PSSnapin $snapinName" -ForegroundColor Yellow
				  Add-PSSnapin $snapinName
		   }
	} 
}
Catch
{
	Write-Host "Error adding Snapin for SharePoint" -foregroundcolor Black -backgroundcolor Red
}
Write-Host ""

#Method to set the Incoming E-mail settings for a list under a site
function EnableIncomingEmailSettings($siteUrl, $listName, $emailAlias){
  
  Try{ 
    $web = Get-SpWeb $siteUrl
    if($web -ne $null){
      $list = $web.Lists[$listName]

      if($list -ne $null){
            $list.EnableAssignToEmail = $true;
            $list.EmailAlias = $emailAlias;          
            $list.Update();

            #Update the properties for the root folder
            
            #Save original e-mail, options 1/0
            $list.RootFolder.Properties["vti_emailsaveoriginal"] = 1;
            #To disable security (accept message from any sender)
            $list.RootFolder.Properties["vti_emailusesecurity"] = 0;
            # Overwrite files with same name
            $list.RootFolder.Properties["vti_emailoverwrite"] = 1;            

            $list.RootFolder.Update();           

            Write-Host "Updated Incoming E-mail settings for site:" $siteUrl ",list:" $listName "with Email:" $emailAlias -ForegroundColor Green
       } 
      else{
            Write-Host "Error fetching list: " $listName -ForegroundColor Red
      }
    }
    
  }
  Catch{
        $ErrorMessage = $_.Exception.Message
		Write-Host "ERROR [$ErrorMessage]" -ForegroundColor Red
  }
  Finally{
    if($web -ne $null){
        $web.Dispose();
     }    
  }
}

EnableIncomingEmailSettings -siteUrl $SiteUrl -listName $ListName -emailAlias $EmailAlias