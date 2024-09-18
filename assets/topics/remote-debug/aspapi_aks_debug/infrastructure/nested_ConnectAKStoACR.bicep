param reference_parameters_resourceName_2021_07_01_identityProfile_kubeletidentity_objectId object
param resourceId_parameters_acrResourceGroup_Microsoft_ContainerRegistry_registries_parameters_acrName string

@description('Specify the name of the Azure Container Registry.')
param acrName string

@description('The unique id used in the role assignment of the kubernetes service to the container registry service. It is recommended to use the default value.')
param guidValue string

resource acrName_Microsoft_Authorization_guidValue 'Microsoft.ContainerRegistry/registries/providers/roleAssignments@2018-09-01-preview' = {
  name: '${acrName}/Microsoft.Authorization/${guidValue}'
  properties: {
    principalId: reference_parameters_resourceName_2021_07_01_identityProfile_kubeletidentity_objectId.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
    scope: resourceId_parameters_acrResourceGroup_Microsoft_ContainerRegistry_registries_parameters_acrName
  }
}
