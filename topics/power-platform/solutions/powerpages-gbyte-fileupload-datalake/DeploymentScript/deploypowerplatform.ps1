

Write-Host "Entering Power Platform Deployment." -ForegroundColor Green
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
Write-Host "Logging you into Cloud:" -ForegroundColor Green
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
1 { $EnvironmentName = Read-Host "Which Existing Env are you deploying to? (cut/paste Environment name here) "}
}

Write-Host " Data Verse Environment $EnvironmentName is ready." -ForegroundColor Green

Write-Host " "
Write-Host " Portal Preparation..  THere are a couple manual steps. See instructions below. Press Enter when complete...... "   -ForegroundColor Green
Write-Host " "
Write-Host " Reference: https://learn.microsoft.com/en-us/power-apps/maker/portals/admin/migrate-portal-configuration?tabs=CLI#prepare-the-target-environment" -ForegroundColor DarkYellow
Write-Host " "
#CREATE CONNECTIONS IN THE TARGET ENVIRONMENT PRIOR TO IMPORTING SOLUTION
Write-Host "STEP 1: In ""$EnvironmentName"" in the Power Apps Studio manually create a new Portal. Go to make.powwerapps select  Apps /New App /Website/Starter Portal" -ForegroundColor Green
Write-Host "STEP 2: In the Portal Managment App, delete the newly created portal record" -ForegroundColor Green
Write-Host "STEP 3: Delete the Portal app in powerapps studio (NOT the portal managment app)" -ForegroundColor Green
Write-Host " "
$continue = Read-Host "IMPORTANT!! Only When previous 3 portal provisioning steps are completed... then press Enter to continue....."

Write-Host " "
Write-Host "Importing Portal Configuration.... to $EnvironmentURL " -ForegroundColor Green
Write-Host "Creating a Target profile. "
pac auth create --environment $EnvironmentName  --Cloud $Cloud --Name "TargetEnvironment"
pac auth select --name "TargetEnvironment"
pac auth list
Write-Host " "
pac paportal upload --path .\portalconfig\starter-portal




Write-Host ""
Write-Host "MANUALLY Create the following connections in $EnvironmentName. When Complete, press the Enter Key....." -ForegroundColor Green
Write-Host ""
Write-Host "Microsoft Teams"  -ForegroundColor Green
Write-Host "Approvals" -ForegroundColor Green
Write-Host "Microsoft Dataverse" -ForegroundColor Green
Write-Host "Office 365 Outlook" -ForegroundColor Green
Write-Host "Office 365 Groups" -ForegroundColor Green
Write-Host "Azure Event Grid" -ForegroundColor Green
Write-Host ""
$continue = Read-Host "IMPORTANT!!  Only When you've completed creating the above Connections ... Press Enter to continue....."

Write-Host " "
Write-Host " Connections created.  Now we'll import the Dataverse Solution...." -ForegroundColor Green
pac solution import --path .\solution\PortalFileUpload.zip

Write-Host " "
Write-Host "Provision a new Portal WebSite with the imported configuration" -ForegroundColor Green
Write-Host " "
Write-Host "In ""$EnvironmentName"" Go to make.powwerapps select  Apps /New App /Website/Starter Portal" -ForegroundColor Green
Write-Host "Select the Checkbox "" Use Data from existing website record. an Select the Starter portal that was imported" -ForegroundColor Green
Write-Host "Reference https://learn.microsoft.com/en-us/power-pages/admin/migrate-site-configuration?tabs=CLI#prepare-the-target-environment" -ForegroundColor DarkYellow
Write-Host " "
$continue = Read-Host " Enter to continue....."

Write-Host " "
Write-Host "All Done! go test your web site.  "


















