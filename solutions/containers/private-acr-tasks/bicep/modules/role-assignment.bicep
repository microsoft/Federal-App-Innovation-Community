param principalId string
param stgAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: stgAccountName
}

var roleAssignmentName = guid(principalId)
resource stgBlobDataContributor 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: roleAssignmentName
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: '${subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')}'
    principalType: 'ServicePrincipal'
  }
}
