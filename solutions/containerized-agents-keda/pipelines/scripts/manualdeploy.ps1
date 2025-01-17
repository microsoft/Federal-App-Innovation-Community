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

$pathToRepo = "Path to the repo root"
$rgName = "Your Rg Name"
$servicePrinicpalSecretName = "clientSecret"

#If you change these, there are other files you will need to change as well
$parametersFile = "main.parameters.json"
$keyVaultName = "eba"

az deployment group create --resource-group  "$rgName" --template-file "$pathToRepo\bicep\main.bicep" --parameters "$pathToRepo\bicep\$parametersFile"

$acrname = az acr list --resource-group $rgName --query [].name -o tsv

. "$pathToRepo\pipelines\scripts\build-images.ps1" -ACR_NAME "$acrname" -RG_NAME "$rgName" -RepoRoot "$pathToRepo" -AgentImage "linux" #-UseDate
. "$pathToRepo\pipelines\scripts\build-images.ps1" -ACR_NAME "$acrname" -RG_NAME "$rgName" -RepoRoot "$pathToRepo" -AgentImage "windows" #-UseDate

#This will provide you the node resource group where the key vault identity lives
az aks show -n eba-keda -g "$rgName" --query nodeResourceGroup -o tsv 

#Put the output of the following command into values-local-dosdev.yaml > linux/windows > keyVault > clientId
#Do this prior to running the helm command
$clientId = az aks show -n eba-keda -g "$rgName" --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv
$acrLoginServer = az acr show -n $acrname -g $rgName --query loginServer -o tsv

#Authenticate to the AKS cluster
az aks get-credentials -g "$rgName" -n "eba-keda"

#Get the service prinicpals secret from the key vault (not acutally used, just an example)
$kedaSpSecret = az keyvault secret show --name "$servicePrinicpalSecretName" --vault-name "$keyVaultName" --query value -o tsv

#Deploy helm chart
.\helm.exe template devops $pathToRepo\helm\. `
    -f $pathToRepo\helm\values-local.yaml `
    --set linux.keyVault.clientId=$clientId `
    --set windows.keyVault.clientId=$clientId `
    --set windows.image.acrLoginServer=$acrLoginServer `
    --set linux.image.acrLoginServer=$acrLoginServer `
    | .\kubectl.exe apply -f -






















#az aks show -n eba-keda -g ephemeralBuildAgents --query oidcIssuerProfile.issuerUrl --output tsv