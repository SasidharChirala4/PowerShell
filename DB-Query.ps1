# Install SqlServer module, if it is not present
if (!Get-Module -ListAvailable -Name SqlServer) {
    Install-Module -Name SqlServer
} 


$FilePath = "\\betst1630\Maildrop$"
$ServerInstance = "BETST0501\SP2016TST"
$DataBase = "SP2016_ContentDB_EdreamsOutlookMiddleware"

try{
    # Get EmailIds from Email table
    $QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $DataBase -Query "SELECT Id FROM Email;"
    $emailIds = $QueryResult  | Select-object  -ExpandProperty  Id

    # Iterate through each and every folder
    Get-ChildItem –Path $FilePath |
    Foreach-Object {
	
	    # Check FileName exists in EmailList
	    if(!($emailIds -contains $_.Name)){
            # Remove folder
            Remove-Item $_.FullName -Recurse -Force
            Write-Host $_.Name 'folder deleted'
        }
    }
}
catch {
  Write-Host "An error occurred:"
  Write-Host $_
}