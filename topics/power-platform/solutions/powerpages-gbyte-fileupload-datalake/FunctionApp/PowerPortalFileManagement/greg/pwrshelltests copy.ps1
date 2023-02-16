#Datalake power shell
#https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-directory-file-acl-powershell

#SET UP VARIBLES 

$connectionstring="DefaultEndpointsProtocol=https;AccountName=fileuploadsgreg;AccountKey=K+s96y5P1kbM0G9SoTdVNo1vgCsQKif32N1oF/V381bgUWIDfQHuaRWwipASj3sIYylTJzvfS6Sn+AStdF8dCA==;EndpointSuffix=core.windows.net"
$ctx = New-AzStorageContext -ConnectionString $connectionstring
$container = "oig"
$blob = "dogsrus/user1lastname/0000000000000010/rode.jpg"
$StartTime = Get-Date
$EndTime = $StartTime.AddMonths(24)
$blobSalURL = New-AzStorageBlobSASToken -Container $container -Blob $blob -Context $ctx -FullUri -Permission r -StartTime $StartTime -ExpiryTime $EndTime
$blobSalURL








