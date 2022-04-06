param location string
param containerName string = 'artifact'


param vnetName string
param storageSubnetName string

var vnetId = resourceId('Microsoft.Network/virtualNetworks',vnetName)
var storageSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets',vnetName,storageSubnetName)

var storageAccountName  = 'stg${uniqueString(resourceGroup().id)}'
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageAccount.name}/default/${containerName}'
}

var stgDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
resource stgDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: stgDnsZoneName
  location: 'global'
  
  resource  vnetLink 'virtualNetworkLinks' = {
    name: 'stgVnetLink'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

resource stgPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'stgPrivateEndpoint${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    subnet: {
      id: storageSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'stgServiceLink${uniqueString(resourceGroup().id)}'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }

  resource privateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'stgDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: stgDnsZone.id
          }
        }
      ]
    }
  }
}

output stgAcctName string = storageAccountName
