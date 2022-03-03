#Connect-PnPOnline -Url 'https://08dev.be.deloitte.com/sites/SasiApps'

#$cUIExtn = "<CommandUIExtension><CommandUIDefinitions><CommandUIDefinition Location='Ribbon.List.Share.Controls._children'><Button Id='Ribbon.List.Share.GetItemsCountButton' Alt='Get list items count' Sequence='11' Command='Invoke_GetItemsCountButtonRequest' LabelText='Get Items Count' TemplateAlias='o1' Image32by32='_layouts/15/images/placeholder32x32.png' Image16by16='_layouts/15/images/placeholder16x16.png'/></CommandUIDefinition></CommandUIDefinitions><CommandUIHandlers><CommandUIHandler Command='Invoke_GetItemsCountButtonRequest' CommandAction='' EnabledScript='javascript: function checkEnable() { return (true);} checkEnable();'/></CommandUIHandlers></CommandUIExtension>"
#Add-PnPCustomAction -Name 'GetItemsCount' -Title 'Invoke GetItemsCount Action' -Description 'Adds custom action to custom list ribbon' -Group 'SiteActions' -Location 'CommandUI.Ribbon' -CommandUIExtension $extn

$extn = "<CustomAction Id='ITIdea.Ribbon.ListItem.Actions.TaskCompletedButton.Script' ScriptSrc='/SiteAssets/Sample.js' Location='ScriptLink' Sequence='100'> </CustomAction>"

Add-PnPCustomAction -Name 'GetItemsCount' -Title 'Invoke GetItemsCount Action' -Description 'Adds custom action to custom list ribbon' -Group 'SiteActions' -Location 'ScriptLink' -CommandUIExtension $extn