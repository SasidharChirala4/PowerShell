Add-PSSnapin Microsoft.Sharepoint.Powershell

#Define these variables 

$WebURL="http://tax-a.be.deloitte.com/W/WBSB00401497350000101"

$ListName ="Project Tasks"

$ReportFile = "C:\Invoice_VersionHistory.csv" 

#delete file if exists

If (Test-Path $ReportFile)

 {

Remove-Item $ReportFile

 }

#Get the Web and List

$Web = Get-SPWeb $WebURL

$List = $web.Lists.TryGetList($ListName) 

 #Check if list exists

 if($List -ne $null)

{

  #Get all list items

  $ItemsColl = $List.Items

  #Write Report Header

  Add-Content -Path $ReportFile -Value "Item ID, Title, Appending" #you could set title for the exporting column

  #Loop through each item

  foreach ($item in $ItemsColl) 

  {

   if($item.id -eq 38)
   {
      #Iterate each version

      foreach($version in $item.Versions)

       {

            #Get the version content

            $VersionData = "$($item.id),  $($version['Title']), $($version['Body'])" #you could select the column you want to export

            #Write to report

            Add-Content -Path $ReportFile -Value $VersionData
        }
   }

  }

 }

Write-Host "Version history has been exported successfully!"