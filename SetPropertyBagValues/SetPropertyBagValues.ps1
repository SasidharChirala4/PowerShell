# This script will Set property bag values
# It should run with a user who has permission to add/update property bag values 
# It should run an environment where SharePointPnPPowerShell2016 module is installed
# Parameters: $SiteUrl - Site url on which we are updating property bag vallues. Example:  http://client-t.be.deloitte.com/C/CUST0009002002 # 
#			: $Properties - Properties with key & value. Example:  Edreams.SiteName:CUST0009002002:true;Edreams.ClientNumber:9002002:true # 
#							Properties are seperated by ";" & Key, values and Indexed are seperated by ":"
# History: Sasidhar 08/07/2019 - Creation      
###################################################################

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$SiteUrl,
	
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$Properties
)

#Ensure that the current script is running with user having enough permissions
$IsCurrentUserStaffedOnCommonSite = Read-Host -Prompt 'Does the current user have full permissions on site? Y/N'
if($IsCurrentUserStaffedOnCommonSite.ToUpper() -eq 'N'){
  throw 'Please run with user having enough permissions on site: '+ $SiteUrl
}
 

# Connect to site using PNP
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Connect-PnPOnline -Url $SiteUrl -CurrentCredentials

try{
	# Read Property key & Values
	$keyValuePairs = $Properties.Split(";")
	foreach($keyValue in $keyValuePairs)
	{	
		# Set/Update PropertyBag Values
		$key,$value,$indexed = $keyValue.split(':')	
		if($indexed -eq "true"){
			Set-PnPPropertyBagValue -Key $key -Value $value -Indexed:$true
		}
		else{
			Set-PnPPropertyBagValue -Key $key -Value $value -Indexed:$false
		}	
		
		Write-Host "PropertyBag value added/updated for key: $key with value: $value" 
	}
}
catch {
	throw "Error setting property bag values !' [$_.Exception.Message]"
}

Write-Host ""
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
