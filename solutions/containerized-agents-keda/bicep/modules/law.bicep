metadata name = 'Log Analytics Workspace'
metadata description = 'Deploy a Log Analytics Workspace'
metadata owner = 'SOE-C 2.0 DT/EI/IM/CVS'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@minLength(4)
@maxLength(63)
@description('The name of the Log Analytics Workspace. This name must be unique within the resource group. It must be alphanumeric, lowercase, and may include hyphens. It must start and end with alphanumerics.')
param ResourceName string

@metadata({
  paramType: 'userConfig'
})
@description('''
Values for the following 5 tags are required for SOE-C compliance.
{
  CostCenter: 
  AppName: 
  Environment: 
  Customer: 
  Requestor: 
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
@description('Reference to the SKU name for the Log Analytics Workspace. Default is PerGB2018. For more information, see https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep#workspacesku')
param SkuName string = 'PerGB2018'

@metadata({
  paramType: 'optionalConfig'
})
@description('The capacity reservation level for the Log Analytics Workspace. Default is 1.')
param CapacityReservationLevel int = 1

@metadata({
  paramType: 'optionalConfig'
})
@description('The resource ID of the cluster that the Log Analytics Workspace is associated with.')
param ClusterResourceId string = ''

@metadata({
  paramType: 'optionalConfig'
})
@description('Enable data export.')
param EnableDataExport bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Purge data immediately after 30 days.')
param ImmediatePurgeDataOn30Days bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The location of the resource.')
param Location string = resourceGroup().location

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  'None'
  'SystemAssigned'
  'UserAssigned'
])
@description('The identity type for the Log Analytics Workspace. Default is SystemAssigned.')
param IdentityType string = 'SystemAssigned'

@metadata({
  paramType: 'optionalConfig'
})
@description('User assigned identity object. Required if IdentityType is UserAssigned.')
param UserAssignedIdentity object = {}

@metadata({
  paramType: 'optionalConfig'
})
@description('Allows public networks to send data to the LAW.')
param PublicNetworkAccessForIngestion string = 'Enabled'

@metadata({
  paramType: 'optionalConfig'
})
@description('Allows public networks to query the LAW.')
param PublicNetworkAccessForQuery string = 'Enabled'

@metadata({
  paramType: 'optionalConfig'
})
@description('Disable local auth. Local auth is considered account key only.')
param DisableLocalAuth bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to enable log access using only resource permissions. Default is false. https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access?tabs=portal')
param EnableLogAccessUsingOnlyResourcePermissions bool = false

//Security Section. Deviations may result in limited or no control inheritance from environment
@metadata({
  paramType: 'securityConfig'
})
@description('Used to give the deployment a unique name')
#disable-next-line no-unused-params // disabling for future use
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')

// ==================================================================================================

// Variables Section
var baseTag = {
  SourceTemplate: 'SOE-C 2.0'
}
var varTags = union(baseTag, Tags)
var builtIdentity = (IdentityType == 'None') 
  ? null
  : (IdentityType == 'SystemAssigned') 
    ? { 
        type: IdentityType
        userAssignedIdentities: null
      } 
    : { 
        type: IdentityType
        userAssignedIdentities: UserAssignedIdentity
      }
var builtSku = (SkuName == 'CapacityReservation')
  ? {
      name: SkuName
      capacityReservationLevel: CapacityReservationLevel
    }
  : {
      name: SkuName
    }

// ==================================================================================================

// Resource Section
resource _logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: ResourceName
  location: Location
  tags: varTags
  identity: builtIdentity
  properties: {
    sku: builtSku
    features: {
      clusterResourceId: ClusterResourceId
      disableLocalAuth: DisableLocalAuth
      enableDataExport: EnableDataExport
      enableLogAccessUsingOnlyResourcePermissions: EnableLogAccessUsingOnlyResourcePermissions
      immediatePurgeDataOn30Days: ImmediatePurgeDataOn30Days
    }
    publicNetworkAccessForIngestion: PublicNetworkAccessForIngestion
    publicNetworkAccessForQuery: PublicNetworkAccessForQuery
  }
}

resource _resourceLock 'Microsoft.Authorization/locks@2020-05-01' = if (DeployResourceLock != null) {
  name: DeployResourceLock.?name ?? '${_logAnalyticsWorkspace.name}lock'
  scope: _logAnalyticsWorkspace
  properties: {
    level: DeployResourceLock.?kind ?? 'CanNotDelete'
  }
}

// ==================================================================================================

// Output Section
output logAnalyticsWorkspaceId string = _logAnalyticsWorkspace.id

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

type tagsType = {
  @description('Cost Center')
  CostCenter: string
  
  @description('Application Name the resource is attached to or a component of')
  AppName: string
  
  @description('Environment Name for this resource')
  Environment: string
  
  @description('The Customer this application is for. Example: DT/EI/IM/CVS')
  Customer: string

  @description('Requestor: Should be a state.gov email address (or other routable email)')
  Requestor: string
  
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
