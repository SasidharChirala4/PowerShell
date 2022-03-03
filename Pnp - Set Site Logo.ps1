#Create a site using PNP
Connect-PnPOnline -Url 'https://08dev.be.deloitte.com/sites/SasiTax' 

#Set SiteLogo
Set-PnPWeb -SiteLogoUrl 'https://08dev.be.deloitte.com/sites/SasiTax/Style%20Library/Logo.jpg'