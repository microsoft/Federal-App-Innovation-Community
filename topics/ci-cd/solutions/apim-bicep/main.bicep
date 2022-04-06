targetScope = 'subscription'

param location string = 'eastus'
param resourceGroupName string = 'apim'

@secure()
param publisherEmail string
param publisherName string

param apimServiceName string = 'apim'
param apimEnv string = 'dev'

param virtualNetworkType string = 'None'
param subnetName string = ''
param vnetName string = ''

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: {
    'environment': apimEnv
    'resource': 'apim'
    'demo': 'true'
  }
}

var apimName = '${apimServiceName}-${apimEnv}-${uniqueString(resourceGroup.id)}'
module serviceConfig 'apim-modules/service/service.bicep' = {
  name: 'serviceConfiguration'
  scope: resourceGroup
  params: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    location: location
    apiManagementServiceName: apimName
    sku: sku
    subnetName: subnetName
    vnetName: vnetName
    apimEnv: apimEnv
    virtualNetworkType: virtualNetworkType
  }
}

module shared 'apim-modules/shared/shared.bicep' = {
  name: 'shared'
  scope: resourceGroup
  params: {
    apimInstance: serviceConfig.outputs.apimInstance
    apimEnv: apimEnv
    
  }
}

module apis 'apim-modules/apis/apis.bicep' = {
  name: 'apis'
  scope: resourceGroup
  params: {
    apimInstance: serviceConfig.outputs.apimInstance
    apimEnv: apimEnv
  }
}
