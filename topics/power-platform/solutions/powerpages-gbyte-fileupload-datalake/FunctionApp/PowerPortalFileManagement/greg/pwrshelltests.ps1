#Datalake power shell
#https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-directory-file-acl-powershell

#SET UP VARIBLES 
$tenantid="3f640d2f-d02f-4c43-9814-6e2360b5c693"
$subscriptionid="6865a616-af4b-4372-95d1-2a17b93cc92f"
$connectionstring="DefaultEndpointsProtocol=https;AccountName=fileuploadsgreg;AccountKey=K+s96y5P1kbM0G9SoTdVNo1vgCsQKif32N1oF/V381bgUWIDfQHuaRWwipASj3sIYylTJzvfS6Sn+AStdF8dCA==;EndpointSuffix=core.windows.net"
$ResourceGroup="FTP"
$StorageAccountName="fileuploadsgreg"
$dept = "testdept"  #dept = containername , the highest level in hierarchy
$companydirectory="testcustomer" #company directory under dept
$username="testuser"  #user subdirectory under companyname   
$userdirectory=$companydirectory+"/"+$username
$usercontainerdirectory=$dept+"/"+$userdirectory
$fileuploadtypeoption = "FTP"

## Write to the Azure Functions log stream.
Write-Host "User Management function processed a request."

$ctx = New-AzStorageContext -ConnectionString $connectionstring

<# $dept = $Request.Query.businessunit      #dept = containername , the highest level in hierarchy
$companydirectory=$Request.Query.companyname #company directory under dept
$username=$Request.Query.contactemail  #user subdirectory under companyname
$fileuploadtypeoption=$Request.Query.fileuploadtypeoption   
$userdirectory=$companydirectory+"/"+$username
$usercontainerdirectory=$dept+"/"+$userdirectory #>

#Write out the input variables to the log
Write-Host "INPUTS: DEPARTMENT: $dept    COMPANY DIRECOTY: $companydirectory     USERNAME: $username     USER DIRECOTY: $userdirectory    FULL USER DIR PATH: $usercontainerdirectory   FILEUPLOAD OPTION: $fileuloadtypeoption "

#CHECK IF A DEPT CONTAINTER EXIST IF NOT CREATE IT    
if(Get-AzStorageContainer -Name $dept -Context $ctx -ErrorAction SilentlyContinue)    #check and see if the container already exists
{
    Write-Host " Department container already exists: $dept"
}
else  #create container if it doesn't exist
{
    New-AzStorageContainer -Name $dept -Permission Off -Context $ctx
    Write-Host " New Deptartment container created: $dept"
}

#CHECK AND SEE IF THE COMPANY DIRECTORY EXISTS IF NOT CREATE IT
if(Get-AzDataLakeGen2Item -FileSystem $dept -Context $ctx -Path $companydirectory  -ErrorAction SilentlyContinue)  
{
    Write-Host " Company Directory already exists: $companydirectory "   
}
else #create company direcory since it does not exist
{
    New-AzDataLakeGen2Item -Context $ctx -FileSystem $dept -Path $companydirectory -Directory
    Write-Host "New Company Directory created:  $companydirectory "
}

#CHECK AND SEE IF THE USER DIRECTORY EXISTS IF NOT CREATE IT
if(Get-AzDataLakeGen2Item -FileSystem $dept -Context $ctx -Path $userdirectory  -ErrorAction SilentlyContinue)    
{
    Write-Host "User directory already exists:  $userdirectory "   
}
else #create the User Directory because it doesn't exist
{
    New-AzDataLakeGen2Item -Context $ctx -FileSystem $dept -Path $userdirectory -Directory
    Write-Host "new User directory created:  $userdirectory " 
}

#CHECK FILEUPLOAD TYPE OPTION AND CREATE CORRESPONDING CREDENTIALS   FTP or SAS TOKEN
if($fileuploadtypeoption = "FTP")
{
    $permissionScope = New-AzStorageLocalUserPermissionScope -Permission rw -Service blob -ResourceName $dept
    $localuser = Set-AzStorageLocalUser -ResourceGroupName $ResourceGroup -StorageAccountName $StorageAccountName -UserName $username -HomeDirectory $usercontainerdirectory  -PermissionScope $permissionScope -HasSshPassword $true
    $password = New-AzStorageLocalUserSshPassword -ResourceGroupName $ResourceGroup -StorageAccountName $StorageAccountName -UserName $username
    $body = "User Name = " + $username + "   Home Directory = " +  $usercontainerdirectory + "   Password = "+ $password
}
else #not FTP so create SASTOken
{
    $datalakesastoken = New-AzDataLakeGen2SasToken -FileSystem $dept -Path $userdirectory -Permission racdwl -FullUri -StartTime (Get-Date) -ExpiryTime (Get-Date).AddDays(6) -Context $ctx  
    $body = "SASuri=" + $datalakesastoken
}

#The Credentials Created
Write-Output "New Credentials Created: $body"

<# # Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
 #>