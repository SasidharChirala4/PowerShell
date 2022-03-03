#------------------------------------------------------
# This script will update DateTime format to standard
# Created On: 27/04/2020
# Created By: Sasidhar
# Parameters: 1.  siteUrlsFile: File path of site urls of ACC Sites.
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteUrlsFile,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)
 
# Global Variables
$CreatedFieldName = 'Created'
$ModifiedFieldName = 'Modified'
$LastSharedByTimeFieldName = 'LastSharedByTime'
$logs = ''

# Update dateTime Format for all webs
function UpdateDateTimeFormatForAllWebs([string]$siteUrl){
    try{
        # Connect to site using PNP
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $siteUrl -CurrentCredentials
        
        # Get root web and update dateTime format
        $rootWeb= Get-PnPWeb        
        UpdateDateTimeFormat($rootWeb)

        # Get all webs under root web  
        $websCollection = Get-PnPSubWebs -Recurse       
        ForEach($web in $websCollection) {           
            # Update dateTime format
            UpdateDateTimeFormat($web)           
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


# Update DateTime Format
function UpdateDateTimeFormat($web){
    try{
        # reconnecting to sub site is required to avoid issues with Set-PnPField.
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $web.Url -CurrentCredentials
        $web= Get-PnPWeb

        # Get all lists in current web    
        $lists= Get-PnPList -Web $web 
        foreach ($list in $lists) {	    
            # Update field DateTime Format
            Set-PnPField -List $list.Title -Identity $CreatedFieldName -Values @{FriendlyDisplayFormat=1}
            Set-PnPField -List $list.Title -Identity $ModifiedFieldName -Values @{FriendlyDisplayFormat=1}                
            Set-PnPField -List $list.Title -Identity $LastSharedByTimeFieldName -Values @{FriendlyDisplayFormat=1} -ErrorAction Ignore              
        }
    
       
		$message = "DateTime format is updated for site:" + $web.Url
		LogWrite $message
		Write-Host $message
    }
    catch{
		$message = "Error while updating DateTime format for site:" + $siteUrl
        LogWrite $message
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
    # Update Office field value
    UpdateDateTimeFormatForAllWebs($_.Trim()) 
}

Write-Host 'Process completed'