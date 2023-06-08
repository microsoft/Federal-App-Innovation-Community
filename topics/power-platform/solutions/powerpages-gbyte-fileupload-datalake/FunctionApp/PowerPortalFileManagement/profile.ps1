# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.


#Connect-AzAccount -Identity -Environment 'AzureUSGovernment' -Subscription '6117ea09-9722-424f-b02f-4e8f50373393' -Tenant '40a3c411-b2a7-4f7b-a28e-05bf8dd7ab7b'
Connect-AzAccount -Identity -Environment $env:Cloud -Subscription $env:Subscription -Tenant $env:Tenant
$ctx = New-AzStorageContext -ConnectionString $env:connectionstring

Import-Module Az.Storage -RequiredVersion '5.3.0'
Import-Module Az.Accounts


# Remove this if you are not planning on using MSI or Azure PowerShell.
<# if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
} #>

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.
# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.


#Connect-AzAccount -Identity -Environment 'AzureUSGovernment' -Subscription '6117ea09-9722-424f-b02f-4e8f50373393' -Tenant '40a3c411-b2a7-4f7b-a28e-05bf8dd7ab7b'
#Connect-AzAccount -Identity -Environment $env:Cloud -Subscription $env:Subscription -Tenant $env:Tenant
#$ctx = New-AzStorageContext -ConnectionString $env:connectionstring

Import-Module Az.Storage -RequiredVersion '5.3.0'
Import-Module Az.Accounts


# Remove this if you are not planning on using MSI or Azure PowerShell.
<# if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
} #>

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.
