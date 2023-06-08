using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed CreateBlobSASTokenFullURI request."

$ctx = New-AzStorageContext -ConnectionString $env:connectionstring

$container   =  $Request.Query.dept
$blobfullname    =  $Request.Query.blobpath

<# $companyname =  $Request.Query.companyname
$contactname =  $Request.Query.contactname
$requestid   =  $Request.Query.requestid
$blobname    =  $Request.Query.blobname
#build blob string
$blobfullname = $companyname + "/" + $contactname + "/" + $requestid + "/" + $blobname #>

Write-Host $blobfullname


$StartTime = Get-Date
$EndTime = $StartTime.AddMonths(24)
$blobSASFULLURI = New-AzStorageBlobSASToken -Container $container -Blob $blobfullname -Context $ctx -FullUri -Permission r -StartTime $StartTime -ExpiryTime $EndTime

Write-Host $blobSASFULLURI

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $blobSASFULLURI
})
