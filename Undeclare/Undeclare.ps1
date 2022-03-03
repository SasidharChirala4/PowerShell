[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Connect-PnPOnline -Url 'https://edreams-a.deloitte.be/Sites/461s4e62/461scxr1' -CurrentCredentials

for($i=1000;$i -lt 3000; $i++){ 
    Write-host $i
    Clear-PnPListItemAsRecord -List "All Documents" -Identity $i
}