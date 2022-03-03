################################################
# This script will configure the require checkout settings on the library
#Parameters:
#  SiteUrl - Site to be configured
#  ListName - Title of the library on which the Force checkout settings needs to be configured
# Created: [Luc Verstrepen - 24/02/2020]
################################################
param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$SiteUrl, 

    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[Boolean]$CheckoutRequired
)


#Method to set the Force checkout settings for a list under a site
function SetRequiredCheckout($siteUrl, $checkoutRequired){

  Try{ 
    Import-Module SharePointPnPPowerShellOnline
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    Connect-PnPOnline -Url $siteUrl -CurrentCredentials
    [string[]] $applicableLists = "Permanent File Accountancy", "Bookkeeping", "Annual Accounts", "Tax Compliance", "PBIPP", "Consolidation", "Tax", "Corporate law", "Commercial law", "Real estate", "Social law", "VAT", "General advice", "Private governance"

    $web = Get-PnPWeb
    Write-Host $web.Url
    if($web -ne $null){
      $lists = Get-PnpList -Includes "RootFolder.Name"
      
      foreach($list in $lists){
            #Write-Host $list.RootFolder.Name
            
            if ($applicableLists.Contains($list.RootFolder.Name))
            {
                Write-Host $list.RootFolder.Name "to be updated to" $checkoutRequired
                Set-PnpList -Identity $list -ForceCheckout $checkoutRequired
                Write-Host $list.RootFolder.Name "successfully updated to" $checkoutRequired
            }
      }

      $subWebs = Get-PnPSubWebs
      foreach ($subWeb in $subWebs){
            Write-Host $subWeb.Url
            $subWebLists = Get-PnpList -Web $subWeb -Includes "RootFolder.Name"

            foreach($subWebList in $subWeblists){
            #Write-Host $subWebList.RootFolder.Name
            
            if ($applicableLists.Contains($subWebList.RootFolder.Name))
            {
                Write-Host $subWebList.RootFolder.Name "to be updated to" $checkoutRequired
                Set-PnpList -Web $subWeb -Identity $subWebList -ForceCheckout $checkoutRequired
                Write-Host $subWebList.RootFolder.Name "successfully updated to" $checkoutRequired
            }
      }

      }
    }
  }
  Catch{
        $ErrorMessage = $_.Exception.Message
		Write-Host "ERROR [$ErrorMessage]" -ForegroundColor Red
  }
  Finally{
    if($web -ne $null){
        #$web.Dispose();
     }    
  }
}

SetRequiredCheckout -siteUrl $SiteUrl -checkoutRequired $CheckoutRequired