#Deployment Script for Backend Azure Function, Datalake and other Azure configuration used with the Power Pages Large File Transfer to datalake solution

#Instructions:
#1 Install PowerShell 7.2 and Azure CLI  ( https://learn.microsoft.com/en-us/cli/azure/install-azure-cli and  https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3 )
#2 Connect-AzAccount     (login to Azure with your GA account credentials from powershell command line)
#3 Enter the Environment Variables below
#4 run script  

# ======DEFAULT ENV VARIABLES============

$defaultResourceGroupName='powerportal'
$defaultDatalakeStorageAccountName = 'DAtaLAKE'
$defaultLocation = 'eastus'  #  usgovvirginia, usgovtexas, usgovarizona(GCC-HIGH)   or usgovarizona,usgovtexas,USGov Iowa (GCC)  or westus3 eastus  eastus2 for Commercial
$defaultFunctionAppName = "FuncDataLakeMgmt"
$defaultCloud = 'AzureCloud'     #  AzCloud for Commercial   AzureUSGovernment for GCC or GCC-HIGH



#=====End Environment Varialbes=================

#Connect-AzAccount -Subscription $Subscription -Tenant $Tenant -Environment $Cloud
#Set-AzContext -Tenant $Tenant -Subscription $Subcription

Write-Host "Deployment Script Started....................."

#List clouds then prompt for which cloud to use
Clear
Write-Host " "
Write-Host " "
(Get-AzEnvironment).Name 
Write-Host " "
$Cloud = Read-Host "Which Cloud are you signing into? (default:$defaultCloud) "
$Cloud = ($defaultCloud,$Cloud)[[bool]$Cloud]
Write-Host "Selected: $Cloud"
Write-Host "Signing in....."
connect-AzAccount -Environment $Cloud


Write-Host " "
Write-Host "Getting Available Deployment Locations....."
Write-Host " "
(Get-AzLocation).Location
Write-Host " "
$Location = Read-Host "Which Location (Region) would you like to deploy to? (default:$defaultLocation) "
$Location = ($defaultLocation,$Location)[[bool]$Location]
Write-Host "Entered: $Location"

$ResourceGroupName = Read-Host "Enter a Resource Group Name? (default:$defaultResourceGroupname) "
$ResourceGroupName = ($defaultResourceGroupName,$ResourceGroupName)[[bool]$ResourceGroupName]
Write-Host "Entered $ResourceGroupName"
$ResourceGroupName = $ResourceGroupName -replace " ",""

$DatalakeStorageAccountName = Read-Host "Enter a Storage Account Name: (default: $defaultDatalakeStorageAccountName)"
$DatalakeStorageAccountName = ($defaultDatalakeStorageAccountName,$DatalakeStorageAccountName)[[bool]$DatalakeStorageAccountName]
Write-Host "Entered  $DatalakeStorageAccountName"
$DatalakeStorageAccountName = $DatalakeStorageAccountName -replace " ",""

$FunctionAppName = Read-Host "Enter a name for the Function App for Storage Management: (default:$defaultFunctionAppName) "
$FunctionAppName = ($defaultFunctionAppName,$FunctionAppName)[[bool]$FunctionAppName]
Write-Host "Entered  $FunctionAppName"
$FunctionAppName = $FunctionAppName -replace " ",""
$AppServicePlanName = $FunctionAppName + "_AppSvcPlan"
$AppInsightsName = $FunctionAppName + "_AppInsights"



#====== Some more defaults
$Tenant = (Get-AzContext).Tenant
$Subscription = (Get-AzContext).Subscription

#===CORS for the Function -- can be edited ---
$CorsRules = (
    @{
    AllowedOrigins=@("*"); 
    ExposedHeaders=@("x-ms-meta-*"); 
    AllowedHeaders=@("Authorization","x-ms-meta-ab","x-ms-meta-target*","x-ms-meta-data*");
    MaxAgeInSeconds=0;
    AllowedMethods=@("PUT","GET","DELETE","HEAD","POST")
    }
)
$indexdoc = "index.html"  #for static web app
$errordoc = "404.html"    #for static web app




#Check if resource gorup exists if not create it
Write-Host "Check if Resource Group $ResourceGroupName exists.  If not create it..........."
if(Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue)    
{
    Write-Host "Resource Group $ResourceGroupName already exists"
}
else  
{
    Write-Host "Creating Resource Group $ResourceGroupName ..... "
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    Write-Host "....Resource Group $ResourceGroupName created"
}

#create datalake
#first check and check if the storage account exists in the resource groups
Write-Host "Checking if Datalake storage Account $DatalakeStorageAccountName already exists.  If not create it with a unique name suffix appended......"
$DatalakeStorageAccountName = $DatalakeStorageAccountName.ToLower()
if(Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object {$_.StorageAccountName.StartsWith($DatalakeStorageAccountName)} )    
{
    $DatalakeStorageAccountName = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object {$_.StorageAccountName.StartsWith($DatalakeStorageAccountName)} ).StorageAccountName
    Write-Host "Storage Account  already exists in the Resource Group: $DatalakeStorageAccountName" 
}
else  #create a new datalake Storage account
{
    Write-Host "Datalake Storage Account does not exist. Creating it........ "
    #create Storage Account with random number appended to make unique
    $DatalakeStorageAccountName = $DatalakeStorageAccountName + ([Random]::new()).Next(1,999999999)
    if ($DatalakeStorageAccountName.Length -gt 24) {$DatalakeStorageAccountName = $DatalakeStorageAccountName.Substring(0,[Math]::Min($DatalakeStorageAccountName.Length,23))}  # TEST THIS TEST THIS
    
    
    Write-Host "Datalake Storage Account does not exist. Creating a new unique name suffix,validate lowercase, and less than 24 characters as required by storage account"
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $DatalakeStorageAccountName -Location $Location -SkuName "Standard_GRS" -Kind StorageV2  -EnableHierarchicalNamespace $true -EnableSftp $true -EnableLocalUser $true
    Write-Host ".......Datalake  created: $DatalakeStorageAccountName "
    
    #enable Static Web Site in the Storage Account created
    Write-Host "Enabling Static Web Site service in Datalake Storage Account ..... "
    $ctx = New-AzStorageContext -StorageAccountName $DatalakeStorageAccountName
    Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $indexdoc -ErrorDocument404Path $errordoc
    Set-AzStorageCORSRule -Context $ctx -ServiceType Blob -CorsRules $CorsRules
    Write-Host ".....Static Web Site Service Enabled "
}


#==Create Function App Serive Plan===
Write-Host "Checking if an App Service Plan for the fuction exists, if not create it..."
if(Get-AzFunctionAppPlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction SilentlyContinue)    
{
    Write-Host "App Service plan already exists"
}
else  
{
    Write-Host "Creating App Service Plan $AppServicePlanName ......"
    New-AzFunctionAppPlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Location $Location -Sku S1 -WorkerType Windows
    Write-Host "...... App Service Plan Created: $appserviceplanename "
}

#create Application Insights for the Function app
Write-Host "Checking if App Insights exist, if not create it..."
if(Get-AzApplicationInsights -ResourceGroupName $ResourceGroupName -Name $AppInsightsName -ErrorAction SilentlyContinue)    
{
    Write-Host "App Insights instance $appinsghtsname already exists"
}
else
{
    Write-host "App Insights instance not there so.. creating App Insights resource $AppInsightsName "
    New-AzApplicationInsights -Location $Location -Kind "web" -Name $AppInsightsName -ResourceGroupName $ResourceGroupName  #note i had to hard code eastus  westus3 did not work
    Write-host "....App Insights Created: $AppInsightsName "
}

#create the Function app

Write-Host "Checking if the Function App exists, if not create it..."
if(Get-AzFunctionApp -ResourceGroupName $ResourceGroupName | Where-Object {$_.Name.StartsWIth($FunctionAppName)} -ErrorAction SilentlyContinue)    
{
    Write-Host "Funtion App $FunctionAppName already exists"
}
else
{
    Write-host "Function App does not exist,  so creating it...... "
    #create a unique function app storage account name and check it to be lower case and nubers less than 24 chars
    $FunctionAppStorageAccountName = $FunctionAppName.ToLower() + ([Random]::new()).Next(1,9999999)
    if($FunctionAppStorageAccountName.Length -gt 23){$FunctionAppStorageAccountName = $FunctionAppStorageAccountName.Substring(0,[Math]::Min($FunctionAppStorageAccountName.Length,23))}  
    
    #create a unique function app name and check it to be lower case and nubers less than 24 chars
    $FunctionAppName = $FunctionAppName + ([Random]::new()).Next(1,9999999)
    if ($FunctionAppName.Length -gt 24) {$FunctionAppName = $FunctionAppName.Substring(0,[Math]::Min($FunctionAppName.Length,24))}  # TEST THIS TEST THIS
   
    #create Functaion App Storage Account
    Write-Host "Creating Storage Account  $FunctionAppStorageAccountName for function app $FunctionAppName ....  "
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $FunctionAppStorageAccountName -Location $Location -SkuName "Standard_GRS" -Kind StorageV2 
    Write-Host "Storage Account for function all created:  $FunctionAppStorageAccountName "
    
    #create the function app
    Write-Host "Creating Function App:  $FunctionAppName ......"
    New-AzFunctionApp  -Name $FunctionAppName -ResourceGroupName $ResourceGroupName -PlanName $AppServicePlanName -Runtime "PowerShell" -RuntimeVersion 7.2 -FunctionsVersion 4 -OSType Windows -StorageAccountName $FunctionAppStorageAccountName -ApplicationInsightsName $AppInsightsName -IdentityType SystemAssigned
    Write-Host "........Function App Created: $FunctionAppName"

    #Assign Role Permission to the Function App System Assignem MI  contributor to the datalake Storage Account
       
    #Get the System Assigned Managed Identity of the new Function App 
    $FuntionAppMI = ( Get-AzADServicePrincipal -DisplayName $FunctionAppName).Id
    Write-Host  "$FunctionAppStorageAccountName managed identity: $FuntionAppMI"

    #Get the Resource ID of the datalake Storage Account
    $DataLakeStorageAccountResourceID = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object {$_.StorageAccountName.StartsWith($DatalakeStorageAccountName)}).Id
    Write-Host "Datalake Storage Account ResourceID  $DataLakeStorageAccountResourceID"

    Write-Host "Assigning contributor permissions for function app $FunctionAppName  with Managed Identity $FuncionAppMI to access Datalake  $DataLakeStorageAccountName  by way of the function app Managed Identity $FuncionAppMI"

    #Assign Contributor Permission Role Assignment to the Function App Managed Identity to be able to read and write to the Datalake Storage Account
    New-AzRoleAssignment -ObjectId $FuntionAppMI -RoleDefinitionName Contributor -Scope $DataLakeStorageAccountResourceID
    Write-Host "Permission Assigned.  Contributor Role Assigment to managed identy: $FunctionAppMI"

    Write-Host "......Function App Deployed: $FunctionAppName"
    
}
#Publish the Function App
Write-Host "Publishing Function App. First zip the current directory. Then Publish ..............."
#set up the zip file name to funcationappname.zip  used in compress and publish steps
Write-Host "creating zip file name based on the function app name + zip extension"
$FunctionAppName = (Get-AzFunctionApp -ResourceGroupName $ResourceGroupName | Where-Object {$_.Name.StartsWIth($FunctionAppName)}).Name 
$FunctionAppDeployment = $FunctionAppName + ".zip"


#Check if there are any previous zip files and delete if exist.  dont want to keep adding them all in the  latest zip
Write-Host "deleting any previous zipped publish files so they aren't included in the latest zip. only want the functions"
Remove-Item  *.zip

#zip the current directory
Write-Host "Compressing the function app into a zip file...."
Compress-Archive -Path .\FunctionApp\PowerPortalFileManagement\* -DestinationPath $FunctionAppDeployment -Force

Write-Host "Publising the latest functions to the function app...."
#05232023 gjr next statement fails.  need to add security context or enable basic auth for  kudo webdeploy general settings on webapp/function app config
Publish-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName -ArchivePath $FunctionAppDeployment -Force
Write-Host ".....Function App Published: $FunctionAppDeployment"

# update the application Settings for the function app
Write-Host "Updating App Connfiguration Settings for Function App:  $FunctionAppName ......"

#Get the Storage Account Connection String
$connectionstring = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $DatalakeStorageAccountName).Context.ConnectionString

#get the ftp endpoint
$ftp_endpoint = ((Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $DatalakeStorageAccountName).PrimaryEndpoints).Blob
$ftp_endpoint = $ftp_endpoint -replace "https://",""
$ftp_endpoint = $ftp_endpoint -replace "/", ""

Update-AzFunctionAppSetting -Name $FunctionAppName -ResourceGroupName $ResourceGroupName -AppSetting @{"Tenant" = $Tenant; "Subscription" = $Subscription; "ResourceGroup" = $ResourceGroupName;"StorageAccountName" = $DatalakeStorageAccountName;"ftp_endpoint" = $ftp_endpoint;"Cloud" = $Cloud;"connectionstring" = $connectionstring}
Write-Host "App Configuration Settings updated for $FunctionAppName"


#Upload the fileupload spa to the Datalake Storage Account Static Website that was created prior
Write-Host "Uploading file upload static web app to the Datalake Storage Account Static web site index in" '$web'
$ctx = New-AzStorageContext -StorageAccountName $DatalakeStorageAccountName
set-AzStorageblobcontent -File "./spa/UploadFileStaticWebApp.html" -Container '$web' -Blob "index.html" -Context $ctx
Write-Host "...Static Web App uploaded"

#Create Event Grid and Subscription
    




#####################################################################################################################

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
##Write-Host "Azure Event Grid" -ForegroundColor Green
Write-Host "When an HTTP request is received" -ForegroundColor Green
Write-Host ""
$continue = Read-Host "IMPORTANT!!  Only When you've completed creating the above Connections ... Press Enter to continue....."

Write-Host " "
Write-Host " Connections created.  Now we'll import the Dataverse Solution...." -ForegroundColor Green
pac solution import --path .\solution\PortalFileUpload.zip  #idea-gjr 05232023 -- change pac solution import solution command to accomodate version in name

Write-Host " "
Write-Host "Provision a new Portal WebSite with the imported configuration" -ForegroundColor Green
Write-Host " "
Write-Host "In ""$EnvironmentName"" Go to make.powwerapps select  Apps /New App /Website/Starter Portal" -ForegroundColor Green
Write-Host "Select the Checkbox "" Use Data from existing website record. an Select the Starter portal that was imported" -ForegroundColor Green
Write-Host "Reference https://learn.microsoft.com/en-us/power-pages/admin/migrate-site-configuration?tabs=CLI#prepare-the-target-environment" -ForegroundColor DarkYellow
Write-Host " "
$continue = Read-Host " Enter to continue....."


###Environment Variables

Write-Host " "
Write-Host "Configuration Environment Variables in the newly created solution" -ForegroundColor Green
Write-Host " "
Write-Host " In Power App Studion open the Environment Varialbles section of the Solution and edit the following Environment Variables:" -ForegroundColor Green
Write-Host " 1) azurefunction_base_url:    Copy the base url or the azure function into the Current value of the Environment Variable azurefunction_base_url. (URL on the overview page of the Azure Function)" -ForegroundColor Green
Write-Host " 2) PPAdmin_email:    copy a value power admin email, the email that the flows will send to the customer. (must have valid license)" -ForegroundColor Green
Write-Host " "
$continue = Read-Host " Enter to continue....."

###ETurn ON the Flows

Write-Host " "
Write-Host "Turn On all the 3 flows" -ForegroundColor Green
Write-Host " "
Write-Host " "
$continue = Read-Host " Enter to continue....."


###Configuration of WebHook in Datablob Trigger to Datalake Event

Write-Host " "
Write-Host "One last thing.. we need to copy the  of WebHook URL of the Datablob Trigger to Datalake new blob Event" -ForegroundColor Green
Write-Host " "
Write-Host " 1) In Power App Studion open the Datalake blob event Power Automate workflow (see imported solution)..  open of the flow, save it, copy the url of the When a HTTP request is received trigger. Publish all customizations in the solution." -ForegroundColor Green
Write-Host "2)  Back in the  Azure Portal, open the datalake resource in the resource group. Click on Events. Click + Event Subscription. Add any name you choose. Give any name to the System Topic. Filer to Event Types: Blob Created.   Endpoint Type: Web Hook. Please Select an endpoint:COPY THE PA URL the the subscriber endpoint " -ForegroundColor Green
Write-Host "Reference https://learn.microsoft.com/en-us/power-pages/admin/migrate-site-configuration?tabs=CLI#prepare-the-target-environment" -ForegroundColor DarkYellow
Write-Host " "
$continue = Read-Host " Enter to continue....."









Write-Host " "
Write-Host " "
Write-Host ".....End of Deployment Script"
Write-Host " "
Write-Host " "
Write-Host "All Done here. Have a Nice Day!!!!"