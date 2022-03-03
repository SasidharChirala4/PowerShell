#------------------------------------------------------
# This script will update Locale value for all DK sites
# Created On: 14/04/2020
# Created By: Sasidhar
# Parameters: 1.  siteUrlsFile: File path of siteCollection urls of DK Sites
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteUrlsFile,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)
 

# Global Variables
$LocaleId = 1033 # English (United States)

# Update Locale Value
function UpdateLocaleValueForAllWebs([string]$siteUrl){
    try{
        # Connect to site using PNP
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $siteUrl -CurrentCredentials
        
        # Get root web and update Locale value
        $rootWeb= Get-PnPWeb
        UpdateLocaleValue($rootWeb)

        # Get all webs under root web
        $websCollection = Get-PnPSubWebs -Recurse 
        ForEach($web in $websCollection) {           
            # Update Locale Value
            UpdateLocaleValue($web)           
        }
    }
    catch{
		$message = "Error at site collection level for url: " + $siteUrl        
        Write-Host $message -ForegroundColor Red
        Write-Host($error)
    }
    finally{
        # Disconnect
        Disconnect-PnPOnline
    }
}

# Update Locale Value
Function UpdateLocaleValue($web){
    try{
        #Update Locale of the web
        $web.RegionalSettings.LocaleId = $LocaleId
        $web.Update()
        Invoke-PnPQuery        
        
		$message = "Locale value updated for site: " + $web.Url
		LogWrite $message
		Write-Host $message -ForegroundColor Green
    }
    catch{
        $message = "Error while setting Locale value for web: " + $web.Url        
        Write-Host $message -ForegroundColor Red
        Write-Host($error)
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
    UpdateLocaleValueForAllWebs($_.Trim()) 
}

Write-Host 'Process completed'