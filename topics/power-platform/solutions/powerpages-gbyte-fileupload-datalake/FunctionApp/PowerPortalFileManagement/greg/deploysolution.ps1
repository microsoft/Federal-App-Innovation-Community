Write-Host "Deployment Script Started"

#GCC Cloud
<# $tenantid="e0ac9796-aafb-4d47-898e-aa4fbc1b15bb"
$subscriptionid="92e0e24b-4bef-4801-806e-6edbe5a72233" #>
$ResourceGroupName="powerpageslargefilesrg"
$location = "westus3"
$storageAccountName = "datalake"
$indexdoc = "index.html"  #for static web app
$errordoc = "404.html"    #for static web app
$CorsRules = (
    @{
    AllowedOrigins=@("*"); 
    ExposedHeaders=@("x-ms-meta-*"); 
    AllowedHeaders=@("Authorization","x-ms-meta-ab","x-ms-meta-target*","x-ms-meta-data*");
    MaxAgeInSeconds=0;
    AllowedMethods=@("PUT","GET","DELETE","HEAD","POST")
    }
)

<# 
Connect-AzAccount
Get-AzSubscription
Get-AzResourceGroup 
#get locations
$locations = Get-AzLocation
$locations | Format-Table -Property DisplayName
$locations

Remove-AzResourceGroup -Name $ResourceGroupName
New-AzResourceGroup -Name gregtest -Location westus3 
Get-AzStorageAccountNameAvailability -Name $storageAccountName
$guid = New-Guid 
Get-AzStorageAccount -ResourceGroupName $ResourceGroupName| Where-Object {$_.StorageAccountName.StartsWith($storageAccountName)}
#>



#create Resource Group
if(Get-AzResourceGroup -Name $ResourceGroupName -Location $location -ErrorAction SilentlyContinue)    
{
    Write-Host "Resource Group already exists"
}
else  #create dept container if it doesn't exist  /dept
{
    New-AzResourceGroup -Name $ResourceGroupName -Location $location
    Write-Host "$ResourceGroupName created"
}


#create datalake
#first check and check if the storage account exists in the resource groups
if(Get-AzStorageAccount -ResourceGroupName $ResourceGroupName| Where-Object {$_.StorageAccountName.StartsWith($storageAccountName)} )    
{
    
    Write-Host "Storage Account  already exists in the Resource Group"
}
else  #create a new datalake Storage account
{
    #create Storage Account with random number appended to make unique
    $storageAccountName = $storageAccountName + ([Random]::new()).Next(1,99999)
    Write-Host "Creating New Datalake Storage Account: $storageAccountName in Resource Group: $ResourceGroupName"
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $storageAccountName -Location $location -SkuName "Standard_GRS" -Kind StorageV2  -EnableHierarchicalNamespace $true -EnableSftp $true -EnableLocalUser $true
    Write-Host "$storageAccountName created"
    $ctx = New-AzStorageContext -StorageAccountName $storageAccountName
    Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $indexdoc -ErrorDocument404Path $errordoc
    Set-AzStorageCORSRule -Context $ctx -ServiceType Blob -CorsRules $CorsRules
}

 