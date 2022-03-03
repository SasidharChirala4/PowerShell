
$username = 'Be_sc_spt_edrsca'
$password = '523BcUs~9CnJI9ER>~#l'
$SiteUrlFilePath = 'C:\$@$!\Powershell\Disable ModernUI\SiteUrls.txt'

$encpassword = convertto-securestring -String $password -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword

foreach($url in Get-Content $SiteUrlFilePath) {
    try
    {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
        Connect-PnPOnline -Url $url -Credentials $cred

        # Opt out from modern lists and libraries at site collection level
        Enable-PnPFeature -Identity E3540C7D-6BEA-403C-A224-1A12EAFEE4C4 -Scope Site

        Disconnect-PnPOnline
        Write-Host 'Modern UI disabled for site ' $url
    }
    catch{}
}