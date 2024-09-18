@description('The name of the API Management service instance')
param apiManagementServiceName string = 'apiservice${uniqueString(resourceGroup().id)}'

@description('The email address of the owner of the service')
@minLength(1)
@secure()
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@allowed([
  'Internal'
  'External'
  'None'
])
param virtualNetworkType string = 'Internal'


param apimEnv string

param subnetName string = ''
param vnetName string = ''

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location


resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apiManagementServiceName
  location: location
  tags: {
    'environment': apimEnv
  }
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: ((!empty(vnetName) && !empty(subnetName)) ? { 
      subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName) 
    } : null)
    virtualNetworkType: virtualNetworkType
  }
}

output apimInstance object = {
  id: apiManagementService.id
  name: apiManagementService.name
  sku: apiManagementService.sku
}
