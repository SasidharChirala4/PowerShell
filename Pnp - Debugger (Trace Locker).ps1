# Debug Provisioning step by step & Track the error

#Connect-PnPOnline -Url 'https://08dev.be.deloitte.com/sites/Acc/Tls'

set-pnptracelog -on -level debug
 
Apply-PnPProvisioningTemplate -Path 'C:\Users\saschirala\Documents\Site Templates\Acc_Tls_Project.xml'