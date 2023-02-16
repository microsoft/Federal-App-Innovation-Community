using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

#this function creates the datalake directory hierarchy for blob upload management for Power Pages External User Large File Transfers
#deptcontainer/companydirectory/contactdirecoty/fileuploadrequestiddiirecoty
#microsoft/companya/johnsmith/0000000000000001

#First connect to the Datalake
#Connect-AzAccount -Identity -Environment $env:Cloud -Subscription $env:Subscription -Tenant $env:Tenant
#Connect-AzAccount -Environment $env:Cloud -Subscription $env:Subscription -Tenant $env:Tenant
$ctx = New-AzStorageContext -ConnectionString $env:connectionstring


#read Query String parameters sent from the HTTP Request Action in Power Automate

$dept = $Request.Query.dept
$companyname = $Request.Query.companyname
$contactname = $Request.Query.contactname  #/dept/company/contact
$requestid= $Request.Query.requestid #/dept/company/contact/fileuploadrequesit
$uploadoption=$Request.Query.uploadoption  #FTP,WEBSMALL,WEBLARGE


#build directory hierarchy variables

$companydirectory = $companyname + "/"
$contactdirectory = $companydirectory + $contactname + "/"
$requestiddirectory = $contactdirectory +  $requestid  #/dept/company/contact/fileuploadrequestid

#FTP variables

$ftpuserhomedirectory = $dept + "/" + $requestiddirectory
$ftpusername = $contactname

# Write to the Azure Functions log stream.

Write-Host "=======================User Management function processed a request =============================="
Write-Host "Department: $dept "
Write-Host "Company: $companyname "
Write-Host "Contact: $contactname "
Write-Host "Request ID: $requestid"
Write-Host "File upload option: $uploadoption "
Write-Host "Company Directory: $companydirectory "
Write-Host "Contact Directory: $contactdirectory "
Write-Host "RequestID Directory: $requestiddirectory"
Write-Host "SFTP User Name: $ftpusername"
Write-Host "FTP User Home Directory: $ftpuserhomedirectory"
Write-Host "================================================================================================="



#CHECK IF A DEPT CONTAINTER EXIST IF NOT CREATE IT    /dept

if(Get-AzStorageContainer -Name $dept -Context $ctx -ErrorAction SilentlyContinue)    #check and see if the container already exists
{
    Write-Host " Department container already exists: $dept"
}
else  #create dept container if it doesn't exist  /dept
{
    New-AzStorageContainer -Name $dept -Permission Off -Context $ctx
    Write-Host " New Deptartment container created: $dept"
}


#CHECK AND SEE IF THE COMPANY DIRECTORY EXISTS IF NOT CREATE IT  /dept/company

if(Get-AzDataLakeGen2Item -FileSystem $dept -Context $ctx -Path $companydirectory  -ErrorAction SilentlyContinue)  
{
    Write-Host " Company Directory already exists: $companydirectory "   
}
else #create company direcory since it does not exist  /dept/company
{
    New-AzDataLakeGen2Item -Context $ctx -FileSystem $dept -Path $companydirectory -Directory
    Write-Host "New Company Directory created:  $companydirectory "
}



#CHECK AND SEE IF THE CONTACT DIRECTORY EXISTS  /dept/company/contact , IF NOT CREATE IT

if(Get-AzDataLakeGen2Item -FileSystem $dept -Context $ctx -Path $contactdirectory  -ErrorAction SilentlyContinue)    
{
    Write-Host "Contact directory already exists:  $contactdirectory "   
}
else #create the CONTACT Directory   because it doesn't exist  /dept/company/contact
{
    New-AzDataLakeGen2Item -Context $ctx -FileSystem $dept -Path $contactdirectory -Directory
    Write-Host "new Contact directory created:  $contactdirectory " 
}



#CHECK AND SEE IF THE FILE REQUEST ID DIRECTORY EXISTS  /dept/company/contact/fileuploadrequestid , IF NOT CREATE IT

if(Get-AzDataLakeGen2Item -FileSystem $dept -Context $ctx -Path $requestiddirectory  -ErrorAction SilentlyContinue)    
{
    Write-Host "File Request ID directory already exists:  $requestiddirectory "   
}
else #create the File Upload Request ID Directory because it doesn't exist  /dept/company/contact/fileuploadrequestid
{
    New-AzDataLakeGen2Item -Context $ctx -FileSystem $dept -Path $requestiddirectory -Directory
    Write-Host "new File Request Id directory created:  $requestiddirectory " 
}



#CHECK FILEUPLOAD TYPE OPTION AND CREATE CORRESPONDING CREDENTIALS   FTP or SAS TOKEN

if($uploadoption -eq 'FTP')
{
    $permissionScope = New-AzStorageLocalUserPermissionScope -Permission rw -Service blob -ResourceName $dept
    $localuser = Set-AzStorageLocalUser -ResourceGroupName $env:ResourceGroup -StorageAccountName $env:StorageAccountName -UserName $ftpusername -HomeDirectory $ftpuserhomedirectory  -PermissionScope $permissionScope -HasSshPassword $true
    $password = New-AzStorageLocalUserSshPassword -ResourceGroupName $env:ResourceGroup -StorageAccountName $env:StorageAccountName -UserName $ftpusername
    $password = $password.SshPassword
    $ftpuserloginbase = $env:StorageAccountName + "." + $ftpusername + "@" + $env:ftp_endpoint
    Write-Host "NEW FTP User, HOME DIRECTOY,  AND PASSWORD CREATED"
    Write-Host "FTP USER Name:" + $ftpusername +  "Password:"+ $password + "Home Directory:" +  $ftpuserhomedirectoy  + "FTP User Login Base:" + $ftpuserloginbase
    $body='{"ftpusername":'+ $ftpusername + ',"password":' + $password + ',"ftpuserloginbase":' + $ftpuserloginbase + '}'
}
else #not FTP so create SASTOken
{
    $datalakesastoken = New-AzDataLakeGen2SasToken -FileSystem $dept -Path $requestiddirectory -Permission racdwl -FullUri -StartTime (Get-Date) -ExpiryTime (Get-Date).AddDays(6) -Context $ctx 
    $body='{"SASuri":' + $datalakesastoken + '}'

}

#The Credentials Created

Write-Output "New Credentials Created: $body"
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
