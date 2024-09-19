metadata requiredFiles = [
  'appServicePlan.bicep'
  'keyVaultAddSecret.bicep'
]
metadata name = 'AppService'
metadata description = 'Deploy an App Service'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@description('The name of the App Service.')
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

// Optional Parameters for configuration
@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  'Windows'
  'Linux'
  'windows'
  'linux'
])
@description('The OS of the app service.')
param AppServiceType string = 'Windows'

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  'App'
  'Elastic'
  'FunctionApp'
  'Linux'
  'Windows'
])
@description('The plan type of the app service.')
param PlanType string = 'App'

@metadata({
  paramType: 'optionalConfig'
})
@description('The managed identity definition for this resource.')
param ManagedIdentities managedIdentitiesType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Deploy the resource lock. This requires a custom role added to your deployment service principal.')
param DeployResourceLock lockType?

@metadata({
  paramType: 'optionalConfig'
})
@description('The location to deploy the object')
param Location string = resourceGroup().location

@metadata({
  paramType: 'optionalConfig'
})
@description('The extended location to deploy the resource')
param ExtendedLocation string?

@metadata({
  paramType: 'optionalConfig'
})
@description('The App Service Plan to use. If not provided, a new one will be created using a P1v3 plan.')
param AppServicePlan resourceIdentifier?

@metadata({
  paramType: 'optionalConfig'
})
@description('The app settings for the app service.')
param AppSettings nameValuePair[]?

@metadata({
  paramType: 'optionalConfig'
})
@allowed ([
  'app'
  'app,linux'
  'app,linux,container'
  'hyperV'
  'app,container,windows'
  'app,linux,kubernetes'
  'app,linux,container,kubernetes'
  'functionapp'
  'functionapp,linux'
  'functionapp,linux,container,kubernetes'
  'functionapp,linux,kubernetes'
])
@description('Setting the kind customizes the interface in the portal. It is read only after created. To determine between windows and linux, use the appServiceType parameter.')
param AppServiceKind string = 'app'

@metadata({
  paramType: 'optionalConfig'
})
@description('Storage accounts can be attached to Linux app services and act as mounted storage.')
param StorageAccountRequired bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The subnet to use for VNet integration.')
param VNetIntegrationSubnet vNetIntegrationSubnetType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to enable VNet image pull.')
param VnetImagePullEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to route all traffic through the VNet.')
param VnetRouteAllEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The IP Rules for the SCM site.')
param ScmIpSecurityRestrictions array = []

@metadata({
  paramType: 'optionalConfig'
})
@description('The IP Rules for the app service.')
param IpSecurityRestrictions array = []

@metadata({
  paramType: 'optionalConfig'
})
@description('Sets the scm site to use the main site IP restrictions.')
param ScmIpSecurityRestrictionsUseMain bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The version of the LinuxFx to use.')
param LinuxFxVersion string?

@metadata({
  paramType: 'optionalConfig'
})
@description('The number of workers to use.')
param NumberOfWorkers int = 1

@metadata({
  paramType: 'optionalConfig'
})
@description('The version of .NET Framework to use.')
param NetFrameworkVersion string?

@metadata({
  paramType: 'optionalConfig'
})
@description('The version of Node.js to use.')
param NodeVersion string?

@metadata({
  paramType: 'optionalConfig'
})
@description('The version of PHP to use.')
param PhpVersion string?

@metadata({
  paramType: 'optionalConfig'
})
@description('The version of PowerShell to use.')
param PowerShellVersion string?

@metadata({
  paramType: 'optionalConfig'
})
@description('The version of Python to use.')
param PythonVersion string?

@metadata({
  paramType: 'optionalConfig'
})
@description('''
  Optional.
  The storage account to use for the app service (AzureWebJobsStorage).
  Blob storage for AzureWebJobsStorage is required for function apps.
  May optional be used with MoveAppServiceContentsToStorageAccount parameter to also store the app service contents in the storage account.
''')
param ByoStorageAccount resourceIdentifier?

@metadata({
  paramType: 'optionalConfig'
})
@description('''
  Setting this to true will add the following app settings to the app service:
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageConnectionString
  WEBSITE_CONTENTSHARE: toLower(resourceName)
  WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
  Must be used with ByoStorageAccount parameter
  Must enabled Azure File Service
  If you choose to bring your own storage account, you must create the azure file share before deployment.
  Azure File Share name must match the function app name.
''')
param MoveAppServiceContentsToStorageAccount bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to enable VNet content share. Used with parameter moveAppServiceContentsToStorageAccount.')
param ContentOverVnet bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The identity that will be used to access the key vault.')
param KeyVaultReferenceIdentity resourceIdentifier?

@metadata({
  paramType: 'optionalConfig'
})
@description('The key vault to store the storage account connection string.')
param KeyVaultForStorageAccount resourceIdentifier?

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to use the always on setting.')
param AlwaysOn bool = true

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to use a 32-bit worker process.')
param Use32BitWorkerProcess bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The size of the container.')
param ContainerSize int?

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to enable http logging.')
param HttpLoggingEnabled bool = true

@metadata({
  paramType: 'optionalConfig'
})
@description('The size limit for the logs directory in MB.')
param LogsDirectorySizeLimitInMB int = 35

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to enable detailed error logging.')
param DetailedErrorLoggingEnabled bool = true

@metadata({
  paramType: 'optionalConfig'
})
@description('The metadata for the site configuration. Used primarily with dotnet 6+ applications')
param SiteConfigMetaData nameValuePair[]?

//Security Section. Deviations may result in limited or no control inheritance from environment
@metadata({
  paramType: 'securityConfig'
})
@allowed([
  'Allow'
  'Deny'
])
@description('The default action for IP security restrictions. Default is Deny.')
param IpSecurityRestrictionsDefaultAction string = 'Deny'

@metadata({
  paramType: 'securityConfig'
})
@allowed([
  'Allow'
  'Deny'
])
@description('The default action for SCM IP security restrictions. Default is Deny.')
param ScmIpSecurityRestrictionsDefaultAction string = 'Deny'

@metadata({
  paramType: 'securityConfig'
})
@allowed([
  'Enabled'
  'Disabled'
  'Null'
])
@description('''
  Whether or not to allow public network access. Default is Enabled. 
  Enabled turns on the firewall.
  Disabled allows only private endpoint.
  Null (as a string) disables the firewall entirely.
  ''')
param PublicNetworkAccess string = 'Enabled'

@metadata({
  paramType: 'securityConfig'
})
@description('The minimum TLS version for the site.')
param MinTlsVersion string = '1.2'

@metadata({
  paramType: 'securityConfig'
})
@description('The minimum TLS version for the SCM site.')
param ScmMinTlsVersion string = '1.2'

@metadata({
  paramType: 'securityConfig'
})
@description('Only accept HTTPS.')
param HttpsOnly bool = true

@metadata({
  paramType: 'securityConfig'
})
@description('Used to give the deployment a unique name')
#disable-next-line no-unused-params // used in the deployment name
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')

// ==================================================================================================

// Variables Section
var baseTag = {
  SourceTemplate: 'SOE-C 2.0'
}
var varTags = union(baseTag, Tags)

var aspId = resourceId(AppServicePlan.?subscriptionId ?? subscription().subscriptionId, AppServicePlan.?resourceGroupName ?? resourceGroup().name, 'Microsoft.Web/serverfarms', AppServicePlan.?name ?? ResourceName)

var vNetIntegrationId = VNetIntegrationSubnet == null
  ? null
  : resourceId(VNetIntegrationSubnet.?subscriptionId ?? subscription().subscriptionId, VNetIntegrationSubnet.?resourceGroupName ?? resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', VNetIntegrationSubnet.?vNetName ?? '', VNetIntegrationSubnet.?subnetName ?? '')

var reserved = toLower(AppServiceType) != 'windows'

// Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }
var formattedUserAssignedIdentities = reduce(
  map(ManagedIdentities.?userAssignedResources ?? [], (id) => { '/subscriptions/${id.?subscriptionId ?? subscription().subscriptionId}/resourceGroups/${id.?resourceGroupName ?? resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${id.name}': {} }),
  {},
  (cur, next) => union(cur, next)
)

var identity = !empty(ManagedIdentities)
  ? {
      type: (ManagedIdentities.?systemAssigned ?? false)
        ? (!empty(ManagedIdentities.?userAssignedResources ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
        : (!empty(ManagedIdentities.?userAssignedResources ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var pna = PublicNetworkAccess == 'Null' ? null : PublicNetworkAccess

var formattedAppSettings = reduce(AppSettings ?? [], {}, (acc, item) => union(acc, {
  '${item.name}': item.value
}))

var storageConnectionString = '@Microsoft.KeyVault(VaultName=${KeyVaultForStorageAccount.?name ?? ''};SecretName=${ResourceName}StorageAccountConnectionString)'

var scmIpRules = ScmIpSecurityRestrictionsUseMain
  ? []
  : ScmIpSecurityRestrictions
// ==================================================================================================

// Resource Section

module appServicePlanResource 'appServicePlan.bicep' = if (AppServicePlan == null) {
  name: 'appServicePlan'
  params: {
    Kind: PlanType
    Sku: {
      name: 'P1v3'
      tier: 'PremiumV3'
      size: 'P1v3'
      family: 'Pv3'
      capacity: 1
    }
    ResourceName: ResourceName
    Tags: varTags
    Location: Location
  }
}

resource _appService 'Microsoft.Web/sites@2022-09-01' = {
  dependsOn: [
    appServicePlanResource
  ]
  name: ResourceName
  location: Location
  tags: varTags
  kind: AppServiceKind
  extendedLocation: !empty(ExtendedLocation)
    ? {
        name: ExtendedLocation
      }
    : null
  identity: identity
  properties: {
    serverFarmId: aspId
    reserved: reserved
    keyVaultReferenceIdentity: !empty(KeyVaultReferenceIdentity)
      ? resourceId(KeyVaultReferenceIdentity.?subscriptionId ?? subscription().subscriptionId, KeyVaultReferenceIdentity.?resourceGroupName ?? resourceGroup().name, 'Microsoft.ManagedIdentity/userAssignedIdentities', KeyVaultReferenceIdentity.?name ?? '')
      : null
    containerSize: ContainerSize ?? 0
    siteConfig: {
      httpLoggingEnabled: HttpLoggingEnabled
      logsDirectorySizeLimit: LogsDirectorySizeLimitInMB
      detailedErrorLoggingEnabled: DetailedErrorLoggingEnabled
      appSettings: union( 
        (ByoStorageAccount != null && MoveAppServiceContentsToStorageAccount) 
          ? [
              {
                name: 'AzureWebJobsStorage'
                value: storageConnectionString
              }
              {
                name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
                value: storageConnectionString
              }
              {
                name: 'WEBSITE_CONTENTSHARE'
                value: toLower(ResourceName)
              }
              {
                name: 'WEBSITE_SKIP_CONTENTSHARE_VALIDATION'
                value: 1
              }
            ]
          : (ByoStorageAccount != null)
            ? [
                {
                  name: 'AzureWebJobsStorage'
                  value: storageConnectionString
                }
              ] 
            : [],
         AppSettings ?? [])
      linuxFxVersion: LinuxFxVersion
      minTlsVersion: MinTlsVersion
      scmMinTlsVersion: ScmMinTlsVersion
      netFrameworkVersion: NetFrameworkVersion ?? 'v4.0'
      metadata: !empty(SiteConfigMetaData)
        ? SiteConfigMetaData
        : []
      nodeVersion: NodeVersion
      numberOfWorkers: NumberOfWorkers
      phpVersion: PhpVersion
      powerShellVersion: PowerShellVersion
      pythonVersion: PythonVersion
      ipSecurityRestrictionsDefaultAction: IpSecurityRestrictionsDefaultAction
      ipSecurityRestrictions: !empty(IpSecurityRestrictions)
        ? IpSecurityRestrictions
        : []
      alwaysOn: AlwaysOn
      use32BitWorkerProcess: Use32BitWorkerProcess
      scmIpSecurityRestrictions: !empty(ScmIpSecurityRestrictions)
        ? scmIpRules
        : []
      scmIpSecurityRestrictionsDefaultAction: ScmIpSecurityRestrictionsDefaultAction
      scmIpSecurityRestrictionsUseMain: ScmIpSecurityRestrictionsUseMain
    }
    publicNetworkAccess: pna
    storageAccountRequired: StorageAccountRequired
    virtualNetworkSubnetId: !empty(vNetIntegrationId)
      ? vNetIntegrationId
      : null
    vnetContentShareEnabled: ContentOverVnet
    vnetImagePullEnabled: VnetImagePullEnabled
    vnetRouteAllEnabled: VnetRouteAllEnabled
    httpsOnly: HttpsOnly
  }
}

resource _storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = if (ByoStorageAccount !=  null) {
  name: ByoStorageAccount.?name ?? 'NoByoStorageAccount'
  scope: resourceGroup(ByoStorageAccount.?subscriptionId ?? subscription().subscriptionId, ByoStorageAccount.?resourceGroupName ?? resourceGroup().name)  
}

module keyVaultSecret 'keyVaultAddSecret.bicep' = if (KeyVaultForStorageAccount != null && ByoStorageAccount != null) {
  name: 'keyVaultSecret'
  scope: resourceGroup(KeyVaultForStorageAccount.?subscriptionId ?? subscription().subscriptionId, KeyVaultForStorageAccount.?resourceGroupName ?? resourceGroup().name)
  params: {
    KeyVaultName: '${KeyVaultForStorageAccount.?name}' ?? ''
    SecretName: '${ResourceName}StorageAccountConnectionString'
    SecretValue: 'DefaultEndpointsProtocol=https;AccountName=${_storageAccount.name};AccountKey=${_storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
}

resource _appSettingsResource 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: _appService
  properties: union( 
    (ByoStorageAccount !=  null && MoveAppServiceContentsToStorageAccount) 
      ? {
          AzureWebJobsStorage: storageConnectionString
          WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageConnectionString
          WEBSITE_CONTENTSHARE: toLower(ResourceName)
          WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
        } 
      : (ByoStorageAccount !=  null)
        ? {
            AzureWebJobsStorage: storageConnectionString
          } 
        : {},
     formattedAppSettings)
}

resource _resourceLock 'Microsoft.Authorization/locks@2020-05-01' = if (DeployResourceLock != null) {
  name: DeployResourceLock.?name ?? '${_appService.name}lock'
  scope: _appService
  properties: {
    level: DeployResourceLock.?kind ?? 'CanNotDelete'
    notes: DeployResourceLock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
}

// ==================================================================================================

// Output Section



// ==================================================================================================

// Type Section

type resourceIdentifier = {
  @description('The name of the resource.')
  name: string

  @description('The resource group name of the resource.')
  resourceGroupName: string?

  @description('The subscription id of the resource.')
  subscriptionId: string?

  @description('The description of the resource.')
  description: string?
}

type vNetIntegrationSubnetType = {
  @description('The name of the VNet.')
  vNetName: string

  @description('The name of the subnet.')
  subnetName: string

  @description('The subscription id of the resource.')
  resourceGroupName: string?

  @description('The subscription id of the resource.')
  subscriptionId: string?

  @description('The description of the resource.')
  description: string?
}

type nameValuePair = {
  @description('The name of the setting.')
  name: string

  @description('The value of the setting.')
  value: string
}

type managedIdentitiesType = {
  @description('Enables system assigned managed identity on the resource.')
  systemAssigned: bool?

  @description('The resource ID(s) to assign to the resource.')
  userAssignedResources: resourceIdentifier[]?
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
  @description('Specify the name of lock.')
  name: string?

  @description('Specify the type of lock.')
  kind: 'CanNotDelete' | 'ReadOnly' | 'None'
}

// ==================================================================================================
