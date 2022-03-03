#------------------------------------------------------
# This script will update Office field default value & property bag value
# Created On: 30/03/2020
# Created By: Sasidhar
# Parameters: 1.  siteUrlsCommaSeperated: Site urls of ACC Sites
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteUrlsCommaSeperated,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)
 

# Global Variables
$FieldName = 'Office'
$PropertyBagKey = '_dttedr_customer_office'
$failedSites = ''

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
                   "Hasselt" { $newDefaultValue = "North-East"}
                   "Kortrijk" { $newDefaultValue = "West"}
                   "Jette" { $newDefaultValue = "Centre-South"}                            
                }

                # Set new default value for Office
                if($newDefaultValue -ne $null){
                    Set-PnPField -List $list.Title -Identity $FieldName -Values @{DefaultValue=$newDefaultValue}                
                }
	        }
        }
    
        # Update Office PropertyBag Value
        if($newDefaultValue -ne $null){        
            Set-PnPPropertyBagValue -Key $PropertyBagKey -Value $newDefaultValue -Indexed true
        }
    }
    catch{
        $failedSites += $siteUrl + "`r`n"
    }
    finally{
        # Disconnect
        Disconnect-PnPOnline
    }
}

# Main Call
$siteUrlsCommaSeperated.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries) | ForEach {

 UpdateOfficeFieldDefaultValue($_)
 
}

# Add failed sites to log file
Add-content $logfile -value $failedSites