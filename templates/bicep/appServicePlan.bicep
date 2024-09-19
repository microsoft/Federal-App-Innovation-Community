metadata requiredFiles = []
metadata name = 'App Service Plan'
metadata description = 'Deploy an App Service Plan for one or more web apps.'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@description('The name of the App Service Plan.')
param ResourceName string

@metadata({
  paramType: 'userConfig'
})
@description('''
{
  AppName: 
  Environment: 
  *:* // Addtional Tags
}
''')
param Tags tagsType

@metadata({
  paramType: 'userConfig'
})
@description('The SKU of the App Service Plan.')
param Sku skuType

@metadata({
  paramType: 'userConfig'
})
@description('Kind of server OS.')
@allowed([
  'App'
  'Elastic'
  'FunctionApp'
  'Windows'
  'Linux'
])
param Kind string

@metadata({
  paramType: 'userConfig'
})
@description('The diagnostic settings of the service. See the type for object construction')
param DiagnosticSettings diagnosticSettingType[]?

// Optional Parameters for configuration
@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to deploy the resource lock. This requires a custom role added to your deployment service principal.')
param DeployResourceLock lockType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Location of the resource. Defaults to the resource group location.')
param Location string = resourceGroup().location

@metadata({
  paramType: 'optionalConfig'
})
@description('The extended location of the App Service Plan.')
param ExtendedLocation string?

@metadata({
  paramType: 'optionalConfig'
})
@description('Defaults to false when creating Windows/app App Service Plan. Required if creating a Linux App Service Plan and must be set to true.')
param Reserved bool = (Kind == 'Linux')

@metadata({
  paramType: 'optionalConfig'
})
@description('The Resource ID of the App Service Environment to use for the App Service Plan.')
param AppServiceEnvironmentId string = ''

@metadata({
  paramType: 'optionalConfig'
})
@description('The Resource ID of the K8s Environment to use for the App Service Plan.')
param KubeEnvironmentId string = ''

@metadata({
  paramType: 'optionalConfig'
})
@description('Target worker tier assigned to the App Service plan.')
param WorkerTierName string = ''

@metadata({
  paramType: 'optionalConfig'
})
@description('If true, apps assigned to this App Service plan can be scaled independently. If false, apps assigned to this App Service plan will scale to all instances of the plan.')
param PerSiteScaling bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan. This affects automatic platform managed scaling out.')
param MaximumElasticWorkerCount int = 1

@metadata({
  paramType: 'optionalConfig'
})
@description('Scaling worker count.')
param TargetWorkerCount int = 0

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  0
  1
  2
])
@description('The instance size of the hosting plan (small, medium, or large).')
param TargetWorkerSize int = 0

@metadata({
  paramType: 'optionalConfig'
})
@description('Zone Redundancy can only be used on Premium or ElasticPremium SKU Tiers within ZRS Supported regions (https://learn.microsoft.com/en-us/azure/storage/common/redundancy-regions-zrs).')
param ZoneRedundancyEnabled bool = false

//Security Section. Deviations may result in limited or no control inheritance from environment
@metadata({
  paramType: 'securityConfig'
})
@description('Used to give the deployment a unique name')
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')

// ==================================================================================================

// Variables Section
var baseTag = {
  SourceTemplate: 'SOE-C 2.0'
}
var varTags = union(baseTag, Tags)
var zoneRedundant = (startsWith(Sku.name, 'P') || startsWith(Sku.name, 'EP')) && ZoneRedundancyEnabled ? true : false

// ==================================================================================================

// Resource Section

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: ResourceName
  kind: Kind
  location: Location
  extendedLocation: !empty(ExtendedLocation)
    ? {
        name: ExtendedLocation
      }
    : null
  tags: varTags
  sku: Sku
  properties: {
    workerTierName: WorkerTierName
    hostingEnvironmentProfile: !empty(AppServiceEnvironmentId)
      ? {
          id: AppServiceEnvironmentId
        }
      : null
    kubeEnvironmentProfile: !empty(KubeEnvironmentId)
      ? {
          id: KubeEnvironmentId
        }
      : null
    perSiteScaling: PerSiteScaling
    maximumElasticWorkerCount: MaximumElasticWorkerCount
    reserved: Reserved
    targetWorkerCount: TargetWorkerCount
    targetWorkerSizeId: TargetWorkerSize
    zoneRedundant: zoneRedundant
  }
}

module diagnosticSettingsResource './appServicePlanDiagnosticSettings.bicep' = {
  name: 'diagnosticSettings-${ResourceName}-${CurrentTime}'
  params: {
    ResourceName: ResourceName
    DiagnosticSettings: DiagnosticSettings
  }
  dependsOn: [
    appServicePlan
  ]
}

resource resourceLock 'Microsoft.Authorization/locks@2020-05-01' = if (DeployResourceLock != null) {
  name: DeployResourceLock.?name ?? '${appServicePlan.name}lock'
  scope: appServicePlan
  properties: {
    level: DeployResourceLock.?kind ?? 'CanNotDelete'
    notes: DeployResourceLock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
}

// ==================================================================================================

// Output Section

output appServicePlanId string = appServicePlan.id

// ==================================================================================================

// Type Section
type diagnosticSettingType = {
  @description('The name of diagnostic setting.')
  name: string?

  @description('The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.')
  metricCategories: metricCategoryType[]?

  @description('A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}

type metricCategoryType = {
  @description('Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
  category: string

  @description('Enable or disable the category explicitly. Default is `true`.')
  enabled: bool

  @description('The time grain of the metric in ISO8601 format. If not specified, the default value is used by passing null.')
  timeGrain: string?
}

type skuType = {
  @description('The name of the SKU.')
  name: string
  
  @description('The capacity of the SKU.')
  tier: string

  @description('The size of the SKU.')
  size: string

  @description('The family of the SKU.')
  family: string

  @description('The model of the SKU.')
  capacity: int

  @description('The scale type of the SKU.')
  locations: string[]?

  @description('The sku capacity of the ASP.')
  skuCapacity: skuCapacityType?

  @description('The capabilities of the SKU.')
  capabilities: {
    name: string
    reason: string?
    value: string?
  }[]?
}

@description('The capacity of the SKU.')
type skuCapacityType = {
  @description('The default capacity of the SKU.')
  default: int

  @description('The maximum capacity of the SKU.')
  elasticMaximum: int

  @description('The maximum scale capacity of the SKU.')
  maximum: int

  @description('The minimum scale capacity of the SKU.')
  minimum: int

  @description('The scale type of the SKU.')
  scaleType: string
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
