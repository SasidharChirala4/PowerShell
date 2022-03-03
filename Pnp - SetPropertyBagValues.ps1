#Create a site using PNP
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Connect-PnPOnline -Url 'https://edreams4-t.be.deloitte.com/Sites/3nfxhdg1/3nfxtz8o' -CurrentCredentials

#Get-PnPPropertyBag
#Set/Update PropertyBag Values
Set-PnPPropertyBagValue -Key "_dttedr_customer_office" -Value "CUST0009002002" -Indexed

