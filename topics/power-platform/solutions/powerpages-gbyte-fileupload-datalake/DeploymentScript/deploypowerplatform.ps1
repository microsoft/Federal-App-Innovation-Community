

Write-Host "Entering Power Platform Deployment." -ForegroundColor DarkCyan
Write-Host " "

$Title = "Logging into Cloud"
$Info = "Choose a Cloud" 
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 Public", "&2 UsGov", "&3 UsGovHigh","&4 UsGovDod")
[int]$defaultchoice = 1
$opt = $host.UI.PromptForChoice($Title,$Info ,$Options,$defaultchoice)
switch($opt)
{
0 { $Cloud = "Public"}
1 { $Cloud = "UsGov"}
2 { $Cloud = "UsGovHigh"}
3 { $Cloud = "UsGovDod"}
}
Write-Host "Logging you into Cloud:"
Write-Host $Cloud -ForegroundColor Green

pac auth clear
pac auth create --name "admin" --cloud $Cloud


pac admin list


$Title = "Create a new Dataverse Environment?"
$Info = "Yes/No" 
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
[int]$defaultchoice = 1
$opt = $host.UI.PromptForChoice($Title,$Info ,$Options,$defaultchoice)
switch($opt)
{
0 { Write-Host "Createing a new Environment"
  $EnvironmentName = Read-Host "Enter an Environment Name: "
  pac admin create --name $EnvironmentName --type Sandbox --region $Cloud
}
1 { $EnvironmentName = Read-Host "Which Env are you deploying to? "}
}

Write-Host " Data Verse Environment $EnvironmentName is ready." -ForegroundColor Green

# PREPARE TARGET PORTAL ENVIRONMENT
# Manual Portal Migration Steps as documented here   https://learn.microsoft.com/en-us/power-apps/maker/portals/admin/migrate-portal-configuration?tabs=CLI#prepare-the-target-environment
#   1st Create a portal manually
#   2nd  In the portal management app, delete that new portal record
#   3rd in Power Apps Studio delete the portal app (NOT the portal management app)
# When you are done, hit the enter key
# 1 pac auth create  -ci "Public" --name "Greg Roe's Environment" --url https://orgec197a1b.crm.dynamics.com/
# pac auth clear
# 
Write-Host " Portal Preparation..    There are a few manual steps as outlined in https://learn.microsoft.com/en-us/power-apps/maker/portals/admin/migrate-portal-configuration?tabs=CLI#prepare-the-target-environment" -ForegroundColor Green

#CREATE CONNECTIONS IN THE TARGET ENVIRONMENT PRIOR TO IMPORTING SOLUTION
Write-Host "Step 1: In $EnvironmentName in the Power Apps Studio manually create a new Portal. Go to make.powwerapps select  Apps /New App /Website/Starter Portal"
Write-Host "Step 2: In the Portal Managment App, delete the newly created portal record"
Write-Host "Step 3: Delete the Portal app in powerapps studio (NOT the portal managment app)"
$continue = Read-Host "WHEN PORTAL IS CREATED.. press any key to continue....."

Write-Host "Importing Solution into $EnvironmentName"
Write-Host "Step  1 First Manually Create the following connections:"
Write-Host "Microsoft Teams"
Write-Host "Approvals"
Write-Host "Microsoft Dataverse"
Write-Host "Office 365 Outlook"
Write-Host "Office 365 Groups"
Write-Host "Azure Event Grid"  ##  WHY IS THIS STILL HERE??? SHOULD BE GONE
$continue = Read-Host "WHEN Connections are CREATED.. press any key to continue....."



#Upload Solution to the new or existing environment
Write-Host "Step 2, automatically Deploying Solution to Environment: $EnvironmentName.  Please stand by..." -ForegroundColor Green







