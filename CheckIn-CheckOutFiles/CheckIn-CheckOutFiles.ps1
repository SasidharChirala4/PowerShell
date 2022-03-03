#------------------------------------------------------
# This script will CheckIn all checked out files by SC_LYnth account
# Created On: 28/04/2020
# Created By: Sasidhar
# Parameters: 1.  siteUrlsFile: File path of site urls.
#             2.  logFile: Log file path
#------------------------------------------------------

param(
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$siteUrlsFile,
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
	[String]$logFile
)

$UserName = 'be\saschirala'

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Start-Transcript

# CheckIn all checked Out files
Function CheckInAllCheckedOutFiles([string]$siteUrl)
{  
    # List to Skip System Lists and Libraries
    $systemLists =@("Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery", 
           "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery","Site Assets", "wfpub")
   
    try
    {
        $siteCollection = Get-SPWeb $siteUrl
        Foreach ($list in $siteCollection.GetListsOfType([Microsoft.SharePoint.SPBaseType]::DocumentLibrary))            
        {
            #Get only Document Libraries & Exclude Hidden System libraries
            if (($list.Hidden -eq $false) -and ($systemLists -notcontains $list.Title))            
            {
                #Define CAML query to filter all checked out files
                $query = New-Object Microsoft.SharePoint.SPQuery
                #$query.Query = "<Where><IsNotNull><FieldRef Name='CheckoutUser' /></IsNotNull></Where>"
                $query.Query = "<Where><Eq><FieldRef Name='CheckoutUser' LookupId='TRUE'/><Value Type='User'>"+ $UserName +"</Value></Eq></Where>"
                $query.ViewAttributes = 'Scope="Recursive"'
                $listItems = $list.GetItems($query)
                  
                if($listItems.count -gt 0)
                {
                    Write-host "Total Number of Checked Out Files Found:"$ListItems.count
                    #Loop through each checked out File
                    ForEach ($item in $listItems) 
                    {
                        Write-Host "'$($item.Url)' is Checked out by: $($item["CheckoutUser"])"
                        #Discard Checkout
                        $Item.File.undocheckout()
                        $Item.File.update()
                    }
                }
            }
        }
    }
    catch
    {
        Write-Host "ERROR - [$($_.Exception.Message)]" -foregroundcolor Red
    }
    finally
    {
        if($siteCollection -ne $null)
        {  
            $siteCollection.Dispose()
        }
    }             
}

    
# Log info to a local file
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $logFile -value $logstring
}


# Main Call
Write-Host 'Process started'
Get-Content $siteUrlsFile | ForEach-Object {
    # Check-In All CheckedOut Files
    CheckInAllCheckedOutFiles($_.Trim()) 
}
Write-Host 'Process completed'

Stop-Transcript