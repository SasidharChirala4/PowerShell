#Create a site using PNP
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

$username= "Be_sc_spt_edrsca"
$password= "VI!8%!(RAxf8#^Ac1*U!"
$encpassword = convertto-securestring -String $password -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Connect-PnPOnline -Url 'https://edreams4-t.be.deloitte.com' -Credentials $cred

#Create Team Site
New-PnPTenantSite -Title "Test Customer Site" -Url "https://edreams4-t.be.deloitte.com/sites/TestCustomerSite" -Template "STS#0" -Owner "be\saschirala" -TimeZone 3  

#Create Enterprice Search Site
#New-PnPTenantSite -Title "Edreams Sasi Apps" -Url "https://08dev.be.deloitte.com/sites/SasiApps" -Template "SRCHCEN#0" -Owner "be\tnesuru" -TimeZone 3
