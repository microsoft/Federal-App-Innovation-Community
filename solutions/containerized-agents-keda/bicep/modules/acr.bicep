param location string
var acrName  = 'ebaacr${uniqueString(resourceGroup().id)}' //to keep it unique

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('kubelet managed identity')
param kubeletPrincipalId string

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

var acrPullRoleAssignmentName = guid(kubeletPrincipalId, resourceGroup().id, 'acr')

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: acrPullRoleAssignmentName
  scope: acr
  properties: {
    principalId: kubeletPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalType: 'ServicePrincipal'
  }
}
