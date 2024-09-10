targetScope = 'subscription'

//RG PARAMS
param rgName string = 'rg-aks-keda-devops'
param location string = 'eastus'

//AKS PARAMS
param aksName string = 'aks-keda-devops'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module aksModule 'modules/aks.bicep' = {
  scope: resourceGroup
  name: 'aksModuleDeployment'
  params: {
    location: location
    name: aksName
  }
}

module acrModule 'modules/acr.bicep' = {
  scope: resourceGroup
  name: 'acrModuleDeployment'
  params: {
    location: location
    kubeletPrincipalId: aksModule.outputs.aksKubeletIdentity
  }
}
