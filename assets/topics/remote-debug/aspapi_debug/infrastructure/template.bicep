targetScope = 'resourceGroup'

param name string = 'ASPDEBUG-${uniqueString(newGuid())}'
param location string
param hostingPlanName string = 'HostPlan-${uniqueString(newGuid())}'
param alwaysOn bool
param sku string
param skuCode string
param phpVersion string
param netFrameworkVersion string


resource name_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: {
  }
  properties: {
    siteConfig: {
      appSettings: []
      phpVersion: phpVersion
      netFrameworkVersion: netFrameworkVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: hostingPlanName_resource.id
    clientAffinityEnabled: true
  }
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  tags: {
  }
  sku: {
    tier: sku
    name: skuCode
  }
  kind: ''
  properties: {
    zoneRedundant: false
  }
  dependsOn: []
}
