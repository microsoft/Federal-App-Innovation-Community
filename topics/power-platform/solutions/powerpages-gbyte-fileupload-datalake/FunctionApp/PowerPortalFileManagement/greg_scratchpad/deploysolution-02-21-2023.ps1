Write-Host "Deployment Script Started"

#GCC Cloud
<# $tenantid="e0ac9796-aafb-4d47-898e-aa4fbc1b15bb"
$subscriptionid="92e0e24b-4bef-4801-806e-6edbe5a72233" #>
$ResourceGroupName="powerpageslargefilesrg"
$Location = "westus3"
$DatalakeStorageAccountName = "DAtaLAKE"
$indexdoc = "index.html"  #for static web app
$errordoc = "404.html"    #for static web app
$AppServicePlanName = "myAppservicePlan"
$FunctionAppName = "FuncDataLakeMgmt"
#$loganalyticsworkspacename = "myLogAnalyticsWorkspace"
$AppInsightsName = "myApplicationinsights"

$CorsRules = (
    @{
    AllowedOrigins=@("*"); 
    ExposedHeaders=@("x-ms-meta-*"); 
    AllowedHeaders=@("Authorization","x-ms-meta-ab","x-ms-meta-target*","x-ms-meta-data*");
    MaxAgeInSeconds=0;
    AllowedMethods=@("PUT","GET","DELETE","HEAD","POST")
    }
)

#Get-AzResourceGroup

#create Resource Group
if(Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue)    
{
    Write-Host "Resource Group already exists"
}
else  
{
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    Write-Host "$ResourceGroupName created"
}

#create datalake
#first check and check if the storage account exists in the resource groups
$DatalakeStorageAccountName = $DatalakeStorageAccountName.ToLower()
if(Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object {$_.StorageAccountName.StartsWith($DatalakeStorageAccountName)} )    
{
    
    Write-Host "Storage Account  already exists in the Resource Group"
}
else  #create a new datalake Storage account
{
    #create Storage Account with random number appended to make unique
    $DatalakeStorageAccountName = $DatalakeStorageAccountName + ([Random]::new()).Next(1,999999999)
    if ($DatalakeStorageAccountName.Length -gt 24) {$DatalakeStorageAccountName = $DatalakeStorageAccountName.Substring(0,[Math]::Min($DatalakeStorageAccountName.Length,23))}  # TEST THIS TEST THIS
    
    Write-Host "Creating Storage Account for the Function App: $FunctionAppStorageAccountName "
    Write-Host "Datalake Storage Account does not exist..."
    Write-Host "...Creating New Datalake Storage Account: $DatalakeStorageAccountName in Resource Group: $ResourceGroupName"
    
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $DatalakeStorageAccountName -Location $Location -SkuName "Standard_GRS" -Kind StorageV2  -EnableHierarchicalNamespace $true -EnableSftp $true -EnableLocalUser $true
    Write-Host "$DatalakeStorageAccountName created"
    
    #enable Static Web Site in the Storage Account created
    $ctx = New-AzStorageContext -StorageAccountName $DatalakeStorageAccountName
    Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $indexdoc -ErrorDocument404Path $errordoc
    Set-AzStorageCORSRule -Context $ctx -ServiceType Blob -CorsRules $CorsRules
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
    Write-Host "$appserviceplanename created"
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
    New-AzApplicationInsights -Location "eastus" -Kind "web" -Name $AppInsightsName -ResourceGroupName $ResourceGroupName  #note i had to hard code eastus  westus3 did not work
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
    Write-Host "Creating Storage Account:  $FunctionAppStorageAccountName "
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $FunctionAppStorageAccountName -Location $Location -SkuName "Standard_GRS" -Kind StorageV2 
    
    #create the function app
    Write-Host "Creating Function App:  $FunctionAppName"
    New-AzFunctionApp  -Name $FunctionAppName -ResourceGroupName $ResourceGroupName -PlanName $AppServicePlanName -Runtime "PowerShell" -RuntimeVersion 7.2 -FunctionsVersion 4 -OSType Windows -StorageAccountName $FunctionAppStorageAccountName -ApplicationInsightsName $AppInsightsName -IdentityType SystemAssigned

    Write-Host "Function App Created $FunctionAppName"

    #Assign Role Permission to the Function App System Assignem MI  contributor to the datalake Storage Account
    Write-Host "Assigning contributor permissions for $FunctionAppName to access $DataLakeStorageAccountName"
    
    #Get the System Assigned Managed Identity of the new Function App 
    $FuntionAppMI = ( Get-AzADServicePrincipal -DisplayName $FunctionAppName).Id
    Write-Host  "$FunctionAppStorageAccountName managed identity: $FuntionAppMI"

    #Get the Resource ID of the datalake Storage Account
    $DataLakeStorageAccountResourceID = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object {$_.StorageAccountName.StartsWith($DatalakeStorageAccountName)}).Id
    Write-Host "Datalake Storage Account ResourceID  $DataLakeStorageAccountResourceID"

    #Assign Contributor Permission Role Assignment to the Function App Managed Identity to be able to read and write to the Datalake Storage Account
    New-AzRoleAssignment -ObjectId $FuntionAppMI -RoleDefinitionName Contributor -Scope $DataLakeStorageAccountResourceID
    Write-Host "Permission Assigned"
    
}

#deploy the function app

az functionapp deployment source config-zip -g greg-powerportal-largefile -n PowerPortalFileManagement --src  PowerPortalFileManagement2.zip

# update the application Settings for the function app




 