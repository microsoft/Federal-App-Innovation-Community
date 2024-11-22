metadata requiredFiles = [
  'logAnalyticsWorkspace.bicep'
  'keyVaultAddSecret.bicep'
]
metadata name = 'Application Insights'
metadata description = 'Deploys an Application Insights resource'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@description('The name of the Application Insights resource.')
param ResourceName string

@metadata({
  paramType: 'userConfig'
})
@description('''
Values for the following 2 tags are required
{
  AppName: 
  Environment: 
  *:* // Addtional Tags
}
''')
param Tags tagsType

// Optional Parameters for configuration
@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to deploy the resource lock. This requires a custom role added to your deployment service principal.')
param DeployResourceLock lockType?

@metadata({
  paramType: 'optionalConfig'
})
@description('If not an empty object, this will attempt to update a keyvault secret with the instrumentation key.')
param KeyVaultInstrumentationKeyUpload keyVaultParamType?

@metadata({
  paramType: 'optionalConfig'
})
@description('If not an empty object, this will attempt to update a keyvault secret with the connection string.')
param KeyVaultConnectionStringKeyUpload keyVaultParamType?

@metadata({
  paramType: 'optionalConfig'
})
@description('If an empty object, this will deploy a new, randomly named Log Analytics workspace. Otherwise, provide as object as following:')
param Workspace workspaceParamType?

@metadata({
  paramType: 'optionalConfig'
})
@description('The location of the resource. This must match the location of the Log Analytics workspace.')
param Location string = resourceGroup().location

@metadata({
  paramType: 'optionalConfig'
})
@description('Specifies whether to purge data immediately after 30 days. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties')
param ImmediatePurgeDataOn30Days bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Specifies the number of days to retain the data. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties')
param RetentionInDays int = 90

@metadata({
  paramType: 'optionalConfig'
})
@description('Specifies the type of application that is associated with the Application Insights resource. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties')
param ApplicationType string = 'web'

@metadata({
  paramType: 'optionalConfig'
})
@description('Specifies the public network access for ingestion is enabled. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties')
param PublicNetworkAccessForIngestion string = 'Enabled'

@metadata({
  paramType: 'optionalConfig'
})
@description('Specifies the public network access for query is enabled. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties')
param PublicNetworkAccessForQuery string = 'Enabled'

@metadata({
  paramType: 'optionalConfig'
})
@description('''
  Specifies whether local authentication is disabled. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties
  https://learn.microsoft.com/en-us/azure/azure-monitor/app/azure-ad-authentication?tabs=net
''')
param DisableLocalAuth bool = false

//Security Section. Deviations may result in limited or no control inheritance from environment
@metadata({
  paramType: 'securityConfig'
})
@description('Specifies whether IP address information is masked in the logs. https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-02-02/components?pivots=deployment-language-bicep#applicationinsightscomponentproperties')
param DisableIpMasking bool = false

@metadata({
  paramType: 'securityConfig'
})
@description('Used to give the deployment a unique name')
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')

// ==================================================================================================

// Variables Section
var autoWorkspaceName = take(uniqueString(ResourceName), 63)

var workspaceId = Workspace == null
  ? '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.OperationalInsights/workspaces/${autoWorkspaceName}'
  : resourceId(Workspace.?subscriptionId ?? subscription().subscriptionId, Workspace.?resourceGroupName ?? resourceGroup().name, 'Microsoft.OperationalInsights/workspaces', Workspace.?workspaceName ?? autoWorkspaceName)

// ==================================================================================================

// Resource Section
module law 'logAnalyticsWorkspace.bicep' = if (Workspace == null) {
  name: 'DeployLAW-${uniqueString(CurrentTime)}'
  params: {
    ResourceName: autoWorkspaceName
    Location: Location
    DeployResourceLock: DeployResourceLock
    IdentityType: 'SystemAssigned'
    Tags: Tags
  }
}

resource _appInsights 'microsoft.insights/components@2020-02-02' = {
  name: ResourceName
  location: Location
  tags: Tags
  kind: ApplicationType
  properties: {
    Application_Type: ApplicationType
    DisableIpMasking: DisableIpMasking
    DisableLocalAuth: DisableLocalAuth
    ImmediatePurgeDataOn30Days: ImmediatePurgeDataOn30Days
    Flow_Type: 'Redfield'
    Request_Source: 'rest'
    RetentionInDays: RetentionInDays
    WorkspaceResourceId: workspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: PublicNetworkAccessForIngestion
    publicNetworkAccessForQuery: PublicNetworkAccessForQuery
  }
  dependsOn: [
    law
  ]
}

module keyVaultSecretInstKey 'keyVaultAddSecret.bicep' = if (KeyVaultInstrumentationKeyUpload != null) {
  name: 'DeployKeyVaultSecret-${uniqueString(CurrentTime)}InstKey'
  scope: resourceGroup(KeyVaultInstrumentationKeyUpload.?subscriptionId ?? subscription().subscriptionId, KeyVaultInstrumentationKeyUpload.?resourceGroupName ?? resourceGroup().name)
  params: {
    SecretName: KeyVaultInstrumentationKeyUpload.?secretName ?? 'AppInsightsInstrumentationKey'
    KeyVaultName: KeyVaultInstrumentationKeyUpload.?keyVaultName ?? ''
    Enabled: true
    SecretValue: _appInsights.properties.InstrumentationKey
  }
  dependsOn: []
}

module keyVaultSecretConnString 'keyVaultAddSecret.bicep' = if (KeyVaultConnectionStringKeyUpload != null) {
  name: 'DeployKeyVaultSecret-${uniqueString(CurrentTime)}ConnString'
  scope: resourceGroup(KeyVaultConnectionStringKeyUpload.?subscriptionId ?? subscription().subscriptionId, KeyVaultConnectionStringKeyUpload.?resourceGroupName ?? resourceGroup().name)
  params: {
    SecretName: KeyVaultConnectionStringKeyUpload.?secretName ?? 'AppInsightsConnectionString'
    KeyVaultName: KeyVaultConnectionStringKeyUpload.?keyVaultName ?? ''
    Enabled: true
    SecretValue: _appInsights.properties.ConnectionString
  }
  dependsOn: []
}

resource resourceLock 'Microsoft.Authorization/locks@2020-05-01' = if (DeployResourceLock != null) {
  name: DeployResourceLock.?name ?? '${_appInsights.name}lock'
  scope: _appInsights
  properties: {
    level: DeployResourceLock.?kind ?? 'CanNotDelete'
    notes: DeployResourceLock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
}

// ==================================================================================================

// Output Section
@description('The Application Insights Resource ID')
output applicationInsightsId string = _appInsights.id

// ==================================================================================================

// Type Section

@description('Use empty strings to deploy to the same resource group and subscription')
type keyVaultParamType = {
  @description('Subscription ID of the key vault')
  subscriptionId: string?

  @description('Resource Group Name of the key vault')
  resourceGroupName: string?

  @description('Name of the key vault')
  keyVaultName: string

  @description('Name of the secret')
  secretName: string?
}

@description('Use empty strings to deploy a new Log Analytics workspace')
type workspaceParamType = {
  @description('Subscription ID of the workspace')
  subscriptionId: string

  @description('Resource Group Name of the workspace')
  resourceGroupName: string

  @description('Name of the workspace')
  workspaceName: string
}

type tagsType = {
  @description('Application Name the resource is attached to or a component of')
  AppName: string
  
  @description('Environment Name for this resource')
  Environment: string
  
  @description('Addtional Tags')
  @minLength(3)
  *: string
}

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Specify the type of lock.')
  kind: 'CanNotDelete' | 'ReadOnly' | 'None'
}

// ==================================================================================================
