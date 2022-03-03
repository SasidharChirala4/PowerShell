if ((Get-PSSnapin | Where { $_.Name -eq "Microsoft.SharePoint.PowerShell" }) -eq $null) {
    Add-PSSnapin Microsoft.SharePoint.PowerShell
}
    
function Get-OpenProjectTasks {
    <#
    .SYNOPSIS
        This is a function which can be used to get open project tasks in Web application level.

    .DESCRIPTION
        This function displays a scenario where we get open project tasks in Web application level. 
        based upon the requirements. 

    .OUTPUTS
        A CSV which lists the ID,Title,Status,AssignedTo,DueDate of each item.

    .EXAMPLE
        Iterate all project tasks http://gateway.be.deloitte.com "C:\Users\saschirala\Downloads\OpenTasks.csv"#>

    Param(
        <# 
        .PARAMETER $SPWebApp
        The URL of the target web application.

        .PARAMETER $OutPutPath
        The storage location for the output CSV file.#>

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $SPWebApp,
        [Parameter(Position = 2, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $OutPutPath
    )

    #This is the array which will store the results later.
    $results = @()
    
    #Counter for the progress bar
    $i = 1
    
    $WebApp = Get-SPWebApplication $SPWebApp 

    $SiteCollections = $WebApp.Sites 

    $SiteCollections | ForEach-Object { 

        Write-Progress -Activity "Site Collection Progress: $($_.name)" -Status "Site Collection: $i of $($SiteCollections.Count)" -PercentComplete (($i / $SiteCollections.Count) * 100)  
        $i++
     
        $siteAssignment = Start-SPAssignment
       
        $SubSites = $_.AllWebs 
       
        $SubSites | ForEach-Object { 
            $webAssignment = Start-SPAssignment
            $lists = $_.Lists | Where-Object { ($_.Title -eq "Project Tasks") }
            $query = new - object Microsoft.SharePoint.SPQuery    
            $caml = "<View><Query><Where><Neq><FieldRef Name='Status'/><Value Type='Choice'>Completed</Value></Neq></Where></Query></View>"    
            $query.Query = $caml 
            $AllItems = $_.GetItems($query)
           
            Foreach ($Item in $Allitems)                 
            {                
                $resultsData = New-Object PSObject 
                $resultsData | Add-Member -type NoteProperty -name "ID" -value $Item.Id 
                $resultsData | Add-Member -type NoteProperty -name "Title" -value $Item["Title"] 
                $resultsData | Add-Member -type NoteProperty -name "Assigned To" -value $Item["ProjectTasksAssignedTo"].LookupValue
                $resultsData | Add-Member -type NoteProperty -name "Status" -value $Item["Status"]
                $resultsData | Add-Member -type NoteProperty -name "Due Date" -value $Item["DueDate"]
                $resultsData | Add-Member -type NoteProperty -name "Modified" -value $Item["Modified"]
                $results += $resultsData                   
            }                  
    
            Stop-SPAssignment $webAssignment
            $_.Dispose()
    
        }
   
        Stop-SPAssignment $siteAssignment
        $_.Dispose()
        
    } 

    #Once all the docs have been checked, we pipe the results to a csv file using the export-csv command. 
    $results | export-csv -Path $OutPutPath -notypeinformation -Force 
       
}

Get-OpenProjectTasks http://acc-t.be.deloitte.com "C:\Users\saschirala\Downloads\OpenTasks.csv"