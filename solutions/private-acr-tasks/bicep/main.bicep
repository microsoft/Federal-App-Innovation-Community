targetScope = 'subscription'

param rgName string
param location string

param vnetName string = 'vnet-example'
param sshKeyValue string

// var vnetId = resourceId('Microsoft.Network/virtualNetworks',vnetName)
// var acrSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets',vnetName,'acr-subnet')
// var storageSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets',vnetName,'storage-subnet')

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
    vnetName: vnetName
    aksSubnetName: 'aks-subnet'
  }
  dependsOn: [
    vnet
  ]
}

module acrModule 'modules/acr.bicep' = {
  scope: resourceGroup
  name: 'acrModuleDeployment'
  params: {
    vnetName: vnetName
    acrSubnetName: 'acr-subnet'
    location: location
  }
  dependsOn: [
    vnet
  ]
}

module storageModule 'modules/storage.bicep' = {
  scope: resourceGroup
  name: 'stgModuleDeployment'
  params: {
    location: location
    storageSubnetName: 'storage-subnet'
    vnetName: vnetName
  }
  dependsOn: [
    vnet
  ]
}

module roleAssignment 'modules/role-assignment.bicep' = {
  scope: resourceGroup
  name: 'roleAssignmentModule'
  params: {
    principalId: acrModule.outputs.acrTaskManagedIdentityPrincipalId
    stgAccountName: storageModule.outputs.stgAcctName
  }
  dependsOn: [
    acrModule
    storageModule
  ]
}
