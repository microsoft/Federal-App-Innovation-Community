param location string
param vnetName string = 'vnet'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'acr-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'storage-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output aksSubnetId string = virtualNetwork.properties.subnets[0].id
output acrSubnetId string = virtualNetwork.properties.subnets[1].id
output storageSubnetId string = virtualNetwork.properties.subnets[2].id
output vnetId string = virtualNetwork.id
