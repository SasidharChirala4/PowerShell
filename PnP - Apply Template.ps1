[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Connect-PnPOnline -Url 'https://edreams4-t.be.deloitte.com/Sites/439whnsc' -CurrentCredentials

#Trace Log
set-pnptracelog -on -level debug

#Apply PnP Template
Apply-PnPProvisioningTemplate -Path "C:\Users\saschirala\Documents\Site Templates\Acc_Customer_Short.xml"