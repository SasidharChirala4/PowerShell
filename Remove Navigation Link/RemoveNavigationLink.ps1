#------------------------------------------------------
# This script will remove Pages navigation link from QuickLaunch
# Created On: 05/04/2021
# Created By: Sasidhar
# Parameters: 1.  webApplicationUrl: Web Application Url
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteCollFileUrl,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)

#region Variables
$Username = "be\be_sc_spl_edrscadk"
$Password = "Dh6~4H6we<l1*qjD74S9W"
#endregion Variables
#region Credentials
[SecureString]$SecurePass = ConvertTo-SecureString $Password -AsPlainText -Force
[System.Management.Automation.PSCredential]$PSCredentials = New-Object System.Management.Automation.PSCredential($Username, $SecurePass)
#endregion Credentials 


# Remove Pages Navigation Link
function RemovePagesNavigationLinkForAllWebs([string]$siteUrl){
    try{
        # Connect to site using PNP
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $siteUrl -Credentials $PSCredentials
        
        # Get root web and remove Pages Navigation Link
        $rootWeb= Get-PnPWeb
        RemovePagesNavigationLink($rootWeb)

        # Get all webs under root web
        $websCollection = Get-PnPSubWebs -Recurse 
        ForEach($web in $websCollection) {           
            # Remove Pages Navigation Link
            RemovePagesNavigationLink($web)           
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

# Remove Pages Navigation Link
Function RemovePagesNavigationLink($web){
    try{
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $web.Url -Credentials $PSCredentials
        #Remove Pages Navigation Link of the web
        Remove-PnPNavigationNode -Title Pages -Location QuickLaunch -Force
        
		$message = "Remove Pages navigation link for site: " + $web.Url
		LogWrite $message
		Write-Host $message -ForegroundColor Green
    }
    catch{
        $message = "Error while remove pages navigation link for web: " + $web.Url        
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

Get-Content $siteCollFileUrl | ForEach-Object {
    # Remove Pages Navigation Link from all webs
    RemovePagesNavigationLinkForAllWebs($_.Trim()) 
}

Write-Host 'Process completed'