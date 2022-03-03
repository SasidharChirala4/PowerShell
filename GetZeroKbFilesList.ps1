#check to see if the PowerShell Snapin is added  
if((Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null) {  
    Add-PSSnapin Microsoft.SharePoint.PowerShell;  
}  
 
## SharePoint DLL   
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")   
$global:currentPhysicalPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path  
   
Function Get-SPWebApplication()  
{    
  Param( [Parameter(Mandatory=$true)] [string]$WebAppURL )  
 return [Microsoft.SharePoint.Administration.SPWebApplication]::Lookup($WebAppURL)  
}  

Function global:Get-SPSite()  
{  
  Param( [Parameter(Mandatory=$true)] [string]$SiteCollURL )  
   
   if($SiteCollURL -ne '')  
    {  
        return new-Object Microsoft.SharePoint.SPSite($SiteCollURL)  
    }  
}  
    
Function global:Get-SPWeb()  
{  
   Param( [Parameter(Mandatory=$true)] [string]$SiteURL )  
    $site = Get-SPSite($SiteURL)  
    if($site -ne $null)  
    {  
    $web=$site.OpenWeb();  
    }  
   return $web  
}  
#EndRegion  
   
Function GetZeroKbFiles([string]$WebAppURL)  
 {   
    try  
    {  
        $results = @()  
         
       #Get the Web Application  
        $WebApp=Get-SPWebApplication($WebAppURL)  
  
        #Arry to Skip System Lists and Libraries  
        $SystemLists =@("Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates",   
                "List Template Gallery", "Theme Gallery", "Reporting Templates",  "Solution Gallery",  
                 "Style Library", "Web Part Gallery","Site Assets", "wfpub","Site Pages") 

                $DocList =@("Permanent File","Annual Accounts", "Bookkeeping","Commercial law","Consolidation","Corporate law","General advice",
                "PB-IPP","Private governance","Real estate","Social law","Tax","Tax Compliance","VAT") 
   
        #Loop through each site collection  
		foreach($Site in $WebApp.Sites)  
        {  
            #Loop through each site in the site collection  
            foreach($Web in $Site.AllWebs)  
            {  
                #Loop through each document library  
                foreach ($List in $Web.GetListsOfType([Microsoft.SharePoint.SPBaseType]::DocumentLibrary))  
                {  
                    #Get only Document Libraries & Exclude Hidden System libraries  
                    if (($List.Hidden -eq $false) -and ($SystemLists -notcontains $List.Title) -and ($DocList -contains $List.Title) )  
                    {  
                        #Loop through eadh Item  
                        foreach ($ListItem in $List.Items)  
                       {  
                            if ($ListItem['File_x0020_Size'] -eq "0")
                            {  
                                $sitecollectionUrl =  "<SiteCollection relativeURL=" + $Site.RootWeb.ServerRelativeURL + "></SiteCollection>"  
                                #Create an object to hold storage data  
                                $resultsData = New-Object PSObject  
                                $resultsData | Add-Member -type NoteProperty -name "SiteCollection Title" -value $Site.RootWeb.Title -Force    
                                $resultsData | Add-Member -type NoteProperty -name "SiteCollection URL" -value $sitecollectionUrl -Force              
                                $resultsData | Add-Member -type NoteProperty -name "Web Title" -value $Web.Title -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Web URL" -value $Web.url -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Library Name" -value $List.Title -Force  
                                $resultsData | Add-Member -type NoteProperty -name "File Name" -value $ListItem.Name -Force  
                                $resultsData | Add-Member -type NoteProperty -name "File URL" -value $Web.Site.MakeFullUrl(“$($Web.ServerRelativeUrl.TrimEnd(‘/’))/$($ListItem.Url)”)  -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Last Modified" -value $ListItem['Modified'].ToString() -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Checked-Out By" -value $ListItem.File.CheckedOutByUser -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Checked-Out By User Email" -value $ListItem.File.CheckedOutBy.Email -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Primary Administrator" -value $Site.Owner -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Primary Administrator Email" -value $Site.Owner.Email -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Secondary Administrator" -value $Site.SecondaryContact -Force  
                                $resultsData | Add-Member -type NoteProperty -name "Secondary Administrator Email" -value $Site.SecondaryContact.Email -Force  
                                $results += $resultsData   
                            }  
                        }  
                    }  
                }  
               $Web.Dispose()           
            }  
            $Site.Dispose()           
        }  
        $results | export-csv -Path $currentPhysicalPath/ListAllCheckedOutFiles.csv -notypeinformation -Force  
         
        #Send message to output console  
        write-host "Zero Kb Files Report Generated Successfully!"  
    }  
    catch [System.Exception]   
    {   
        write-host -f red $_.Exception.ToString()   
    }   
}  

# Function Call  
$WebApp = Read-Host "https://spportal.deloitte.be/"  
GetZeroKbFiles $WebApp  
