#------------------------------------------------------
# This script will update Private Governance library name to PRG Advisory
# Created On: 15/09/2020
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

$ListName = "PRG Governance"
$ContentType1 = "FIDU - PRG - Governance Document"
$ContentType2 = "FIDU - PRG - Governance Mail"
$Field = "dttedrDocumentTypePrivateGovernance"

# Change Library Url
function RemoveContentTypes([string]$siteUrl)
{  
    try{
        #Connect to PNP Online
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $siteUrl -CurrentCredentials
 
        #Get the List
        #Remove-PnPFieldFromContentType -Field $Field -ContentType $ContentType1
		#Remove-PnPFieldFromContentType -Field $Field -ContentType $ContentType2
		Remove-PnPField -List $ListName -Identity $Field -Force
		$message = "Field is Removed from List: " + $siteUrl
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
    RemoveContentTypes($_.Trim()) 
}

Write-Host 'Process completed'
