# This script will set AssociatedMembes to read-only for all the TLS Libraries
# It should run with a user who has permission to modify library
# It should run an environment where SharePointPnPPowerShell2016 module is installed
# Parameters: $filePath - File path of text file with has all the site urls
# History: Luc 31/01/2022 - Creation      
###################################################################

param(	
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$filePath
)

# List of libraries
$libraries = "Commercial%20law","Corporate%20law","Social%20law","Real estate","Tax","Vat"

# Update library permissions
function UpdatePermissionsForLibrary([string]$libraryName, [string]$memberGroupTitle){	
	$list = Get-PnPList -Identity $libraryName -Includes RoleAssignments
	#$roleAssignments = Get-PnPProperty -ClientObject $list -Property RoleAssignments
	$list.BreakRoleInheritance($true,$true)
	$list.Update()
	Set-PnPList -Identity $libraryName -BreakRoleInheritance
	Set-PnPListPermission -Identity $libraryName -Group "Document Managers" -RemoveRole "Contribute"
	Set-PnPListPermission -Identity $libraryName -Group "Document Managers" -AddRole "Read"
	Set-PnPListPermission -Identity $libraryName -Group "Location Based Support Groups" -RemoveRole "Contribute"
	Set-PnPListPermission -Identity $libraryName -Group "Location Based Support Groups" -AddRole "Read"
	Set-PnPListPermission -Identity $libraryName -Group "Undeclare Members" -RemoveRole "Edit"
	Set-PnPListPermission -Identity $libraryName -Group "Undeclare Members" -AddRole "Read"
	Set-PnPListPermission -Identity $libraryName -Group $memberGroupTitle -RemoveRole "Contribute"
	Set-PnPListPermission -Identity $libraryName -Group $memberGroupTitle -AddRole "Read"
}

# Main Call
Write-Host 'Process started'

Get-Content $filePath | ForEach-Object {
	Write-Host "Processing for site with url:" $_.Trim()
    # Connect to site
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
	Connect-PnPOnline $_.Trim() -CurrentCredentials	
	$membersGroup = Get-PnPGroup -AssociatedMemberGroup
	
	foreach ($library in $libraries) {
	  # Update library permissions
	  UpdatePermissionsForLibrary $library $membersGroup.Title
	}
	
	# Disconnect
	Disconnect-PnPOnline	
}

Write-Host 'Process completed'