# This script will Add terms for TLS
# It should run with a user who has permission to add/update terms 
# It should run an environment where SharePointPnPPowerShell2016 module is installed
# Parameters: $entrySiteUrl - EntrySite url on which we are adding terms. Example:  https://edreams4-t.be.deloitte.com/ 
#			  $xmlFilePath - File path of xml with terms to add
# History: Sasidhar 18/01/2022 - Creation      
###################################################################

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$entrySiteUrl,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$xmlFilePath
)

#Ensure that the current script is running with user having enough permissions
$IsCurrentUserStaffedOnCommonSite = Read-Host -Prompt 'Does the current user have full permissions to add Terms? Y/N'
if($IsCurrentUserStaffedOnCommonSite.ToUpper() -eq 'N'){
  throw 'Please run with user having enough permissions'
}

try
{
	Write-Host "Connecting to "$entrySiteUrl
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
	Connect-PnPOnline -Url $entrySiteUrl -CurrentCredentials
	
	Write-Host "Importing terms..."
	Import-PnPTermGroupFromXml -Path $xmlFilePath
	#Export-PnPTermGroupToXml -Out output.xml
	Write-Host "e-DReaMS prerequisite terms have been created/appended." -ForeGroundColor Green
}
catch
{
	Write-Host $_.Exception.Message -ForegroundColor Red
	Disconnect-PnPOnline -ErrorAction SilentlyContinue
	throw
}
