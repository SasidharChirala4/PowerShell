#------------------------------------------------------
# This script will update Office field default value & property bag value
# Created On: 30/03/2020
# Created By: Sasidhar
# Parameters: 1.  siteUrlsFile: File path of site urls of ACC Sites
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteUrlsFile,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)
 

# Global Variables
$FieldName = 'Office'
$PropertyBagKey = '_dttedr_customer_office'
$logs = ''

# Update Office Field Default Value
function UpdateOfficeFieldDefaultValue([string]$siteUrl){
    try{
        $newDefaultValue = $null

        # Connect to site using PNP
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $siteUrl -CurrentCredentials
    
        $web = Get-PnPWeb
    
        # Get all lists in current web    
        $lists= Get-PnPList -Web $web 
        foreach ($list in $lists) {
	    
            # Get Office field
            $field = Get-PnPField -List $list.Title -Identity $FieldName -ErrorAction Ignore
	        if($field -ne $null)
	        {
		        $defaultValue = $field.DefaultValue
                switch($defaultValue){
                   "Antwerpen" { $newDefaultValue = "North-East"}
				   "Leuven" { $newDefaultValue = "North-East"}
                   "Brugge" { $newDefaultValue = "West"}
				   "Gent" { $newDefaultValue = "West"}
				   "Roeselare" { $newDefaultValue = "West"}
                   "Charleroi" { $newDefaultValue = "Centre-South"} 
				   "Liège" { $newDefaultValue = "Centre-South"} 				   
                }

                # Set new default value for Office
                if($newDefaultValue -ne $null){
                    Set-PnPField -List $list.Title -Identity $FieldName -Values @{DefaultValue=$newDefaultValue}                
                }
	        }
        }
    
        # Update Office PropertyBag Value
        if($newDefaultValue -ne $null){        
            Set-PnPPropertyBagValue -Key $PropertyBagKey -Value $newDefaultValue -Indexed
        }
		$message = "Office field default value is updated for site:" + $siteUrl
		LogWrite $message
		Write-Host $message
    }
    catch{
		$message = "Error while setting Office default value for site:" + $siteUrl
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
    # Update Office field value
    UpdateOfficeFieldDefaultValue($_.Trim()) 
}

Write-Host 'Process completed'