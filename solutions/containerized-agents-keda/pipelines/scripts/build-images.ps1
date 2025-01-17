#------------------------------------------------------------------------------
#
# Copyright © 2024 Microsoft Corporation.  All rights reserved.
#
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED "AS IS" WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
#------------------------------------------------------------------------------
param (
    [Parameter(Mandatory=$true)]
    [string]$ACR_NAME,

    [Parameter(Mandatory=$true)]
    [string]$RG_NAME,

    [Parameter(Mandatory=$true)]
    [string]$RepoRoot,

    [Parameter(Mandatory=$true)]
    [ValidateSet("linux", "windows")]
    [string]$AgentImage,

    [switch]$UseDate
)

$date = Get-Date -Format "yyyyMMdd"
if ($useDate)
{
    $imageName = "$($AgentImage)-agent:$date"
}
else 
{
    $imageName = "$($AgentImage)-agent:latest"
}
$platform = if ($AgentImage -eq "windows") { "windows" } else { "linux" }
Write-Host "Building and pushing image: $imageName"

az acr build `
    --only-show-errors `
    --registry $ACR_NAME `
    --resource-group $RG_NAME `
    --image $imageName `
    --platform $Platform `
    "$($RepoRoot)/dockeragent/$($AgentImage)/."