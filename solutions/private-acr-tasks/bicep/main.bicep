targetScope = 'subscription'

param rgName string
param location string

param vnetName string = 'vnet'
param sshKeyValue string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module vnet 'modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'vnetModuleDeployment'
  params: {
    location: location
    vnetName: vnetName
  }
}

module aksModule 'modules/aks.bicep' = {
  scope: resourceGroup
  name: 'aksModuleDeployment'
  params: {
    location: location
    sshKeyValue: sshKeyValue
    vnetSubnetId: vnet.outputs.aksSubnetId
  }
}

module acrModule 'modules/acr.bicep' = {
  scope: resourceGroup
  name: 'acrModuleDeployment'
  params: {
    vnetId: vnet.outputs.vnetId
    location: location
    acrSubnetId: vnet.outputs.acrSubnetId
  }
}

module storageModule 'modules/storage.bicep' = {
  scope: resourceGroup
  name: 'stgModuleDeployment'
  params: {
    location: location
    storageSubnetId: vnet.outputs.storageSubnetId
    vnetId: vnet.outputs.vnetId
  }
}
