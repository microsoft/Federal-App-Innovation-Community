targetScope = 'resourceGroup'

param name string 
param location string = resourceGroup().location

resource acrdebug490840984 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: {
  }
}
