#Deployment Script for Backend Azure Function, Datalake and other Azure configuration used with the Power Pages Large File Transfer to datalake solution

#Instructions:
#1 Install PowerShell 7.2 and Azure CLI  ( https://learn.microsoft.com/en-us/cli/azure/install-azure-cli and  https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3 )
#2 Connect-AzAccount     (login to Azure with your GA account credentials from powershell command line)
#3 Enter the Environment Variables below
#4 run script  

# ======Enter Environment Varialbles============
$Tenant = "8b46d3b4-b4ac-4e33-8e31-1ee00f0d9aab"
$Subscription = "08b808a3-b7be-41b0-81d0-9db588fd5ce3"
$Cloud = "AzureCloud"     #  AzCloud for Commercial   AzureUSGovernment for GCC or GCC-HIGH
$ResourceGroupName="rg-greg-testing123-again"
$Location = " eastus"  #  usgovvirginia, usgovtexas, usgovarizona(GCC-HIGH)   or usgovarizona,usgovtexas,USGov Iowa (GCC)  or westus3 eastus  eastus2 for Commercial
$DatalakeStorageAccountName = "DAtaLAKE"
$indexdoc = "index.html"  #for static web app
$errordoc = "404.html"    #for static web app
$AppServicePlanName = "myAppservicePlan"
$FunctionAppName = "FuncDataLakeMgmt"
$AppInsightsName = "myApplicationinsights"
$AppInsightsRegion = "eastus"
$CorsRules = (
    @{
    AllowedOrigins=@("*"); 
    ExposedHeaders=@("x-ms-meta-*"); 
    AllowedHeaders=@("Authorization","x-ms-meta-ab","x-ms-meta-target*","x-ms-meta-data*");
    MaxAgeInSeconds=0;
    AllowedMethods=@("PUT","GET","DELETE","HEAD","POST")
    }
)
#=====End Environment Varialbes=================

#Connect-AzAccount -Subscription $Subscription -Tenant $Tenant -Environment $Cloud
#Set-AzContext -Tenant $Tenant -Subscription $Subcription

Write-Host "Deployment Script Started....................."

#App Configuration Settings
#$Tenant =(Get-AzTenant).Id                               
#$Subscription = (Get-AzSubscription -TenantId $Tenant).Id   # or enter manually
#$Cloud = ((az cloud show) | ConvertFrom-Json).name          # or manually Set to AzureUSGovernment for GCC and GCC-High ; AzureCloud for Azure Commercial

#Get-AzResourceGroup

#create Resource Group
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
    New-AzApplicationInsights -Location $AppInsightsRegion -Kind "web" -Name $AppInsightsName -ResourceGroupName $ResourceGroupName  #note i had to hard code eastus  westus3 did not work
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
Compress-Archive -Path * -DestinationPath $FunctionAppDeployment -Force

Write-Host "Publising the latest functions to the function app...."
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
    


Write-Host " "
Write-Host " "
Write-Host ".....End of Deployment Script"
Write-Host " "
Write-Host " "
Write-Host "All Done here. Have a Nice Day!!!!"