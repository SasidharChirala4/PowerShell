# This script will Enable/Deprecate Terms
# It should run with a user who has permission to add/update terms 
# It should run an environment where SharePointPnPPowerShell2016 module is installed
# Parameters: $entrySiteUrl - EntrySite url on which we are adding terms. Example:  https://edreams4-t.be.deloitte.com/ 
#			  $deprecateTerms - Identifies to Enabel/Deprecate the terms
#			  $textFilePath - File path of text file with terms to deprecate
# History: Sasidhar 31/01/2022 - Creation      
###################################################################

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$entrySiteUrl,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[Boolean]$deprecateTerms,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$textFilePath
)

try
{
	Write-Host "Connecting to "$entrySiteUrl
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
	Connect-PnPOnline -Url $entrySiteUrl -CurrentCredentials
	
	Write-Host "Enable/Deprecate terms..."
	Get-Content $textFilePath | ForEach-Object {
		# Enable/Deprecate terms
		Set-PnPTerm -Identity $_.Trim() -Deprecated $deprecateTerms 
	}	
}
catch
{
	Write-Host $_.Exception.Message -ForegroundColor Red
	Disconnect-PnPOnline -ErrorAction SilentlyContinue
	throw
}
