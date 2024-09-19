metadata requiredFiles = [
  'keyVaultAccessPolicy.bicep'
]
metadata name = 'Key Vault'
metadata description = 'Deploys a Key Vault'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@description('Name of the Key Vault to be created')
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
@description('An array of strings consisting of the full resource IDs of all subnets that the keyvault\'s service endpoint will allow access from.')
param ConnectedSubnetResourceIds virtualNetworkRuleType[] = []

@metadata({
  paramType: 'userConfig'
})
@description('Determines whether the key vault is deployed with a private endpoint. If not, it deploys using service endpoints and the firewall.')
param DeployForPrivateEndpoint bool

// Optional Parameters for configuration
@metadata({
  paramType: 'optionalConfig'
})
@description('Array of diagnostic settings to be added to the Key Vault.')
param diagnosticSettings diagnosticSettingType[]?

@metadata({
  paramType: 'optionalConfig'
})
@description('''
Array of access policies to be added to the Key Vault.
This template removes all access policies from the vault each deployment and add the policies specified here.
If you want to add to the existing policies, you must include the existing policies in this array, or call the accessPolicy.bicep as a stand alone deployment.
''')
param AccessPolicies accessPoliciesType[]?

@metadata({
  paramType: 'optionalConfig'
})
@description('Whether or not to deploy the resource lock. This requires a custom role added to your deployment service principal.')
param DeployResourceLock lockType?

@metadata({
  paramType: 'optionalConfig'
})
@description('The location to deploy the resource.')
param Location string = resourceGroup().location

@metadata({
  paramType: 'optionalConfig'
})
@description('SKU for the vault')
param Sku string = 'Standard'

@metadata({
  paramType: 'optionalConfig'
})
@allowed(['default', 'recover'])
param CreateMode string = 'default'

@metadata({
  paramType: 'optionalConfig'
})
@description('Determines whether the key vault is deployed with soft delete enabled')
param VaultEnableSoftDelete bool = true

@metadata({
  paramType: 'optionalConfig'
})
@minValue(7)
@maxValue(90)
@description('Specifies the number of days that items are retained in the soft delete recovery window. Must be between 7 and 90 days')
param VaultSoftDeleteRetentionInDays int = 90

@metadata({
  paramType: 'optionalConfig'
})
@description('Specifies whether VMs can access certificates stored as secrets in this key vault')
param EnabledForDeployment bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Enables the key vault to be referenced by an Azure Resource Manager deployment, under the deploying identitys credentials')
param EnabledForTemplateDeployment bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Enables the key vault to store secrets relating to Azure Disk Encryption (BEK and KEK)')
param EnabledForDiskEncryption bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('See this link for values: https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep#networkruleset')
param ByPassNetworkAcls string = 'None'

//Security Section. Deviations may result in limited or no control inheritance from environment
@metadata({
  paramType: 'securityConfig'
})
@allowed(['Deny', 'Allow'])
@description('Determiners whether the default action of the network ACL is to allow or deny. Case-sensitive.')
param NetworkAclDefaultAction string = 'Deny'

@metadata({
  paramType: 'securityConfig'
})
@description('Key Vault Firewall Rule IP Ranges Array')
param IpRules array = []

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
var tenantId = subscription().tenantId
var publicNetworkAccess = DeployForPrivateEndpoint ? 'Disabled' : 'Enabled'
var vaultEnablePurgeProtection = true

// ==================================================================================================

// Resource Section
resource _keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: ResourceName
  location: Location
  tags: varTags
  properties: {
    createMode: CreateMode
    enabledForDeployment: EnabledForDeployment
    enabledForTemplateDeployment: EnabledForTemplateDeployment
    enabledForDiskEncryption: EnabledForDiskEncryption
    enableSoftDelete: VaultEnableSoftDelete
    softDeleteRetentionInDays: VaultSoftDeleteRetentionInDays
    enablePurgeProtection: vaultEnablePurgeProtection
    accessPolicies: []
    publicNetworkAccess: publicNetworkAccess
    tenantId: tenantId
    sku: {
      name: Sku
      family: 'A'
    }
    networkAcls: {
      bypass: ByPassNetworkAcls
      defaultAction: NetworkAclDefaultAction
      ipRules: IpRules
      virtualNetworkRules: [
        for subnetId in ConnectedSubnetResourceIds: {
          id: resourceId(subnetId.?subscriptionId ?? subscription().subscriptionId, subnetId.?resourceGroupName ?? resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', subnetId.vnetName, subnetId.subnetName)
          ignoreMissingVnetServiceEndpoint: subnetId.ignoreMissingVnetServiceEndpoint
        }
      ]
    }
  }
}

resource _keyVaultDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${_keyVault.name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? [{ categoryGroup: 'allLogs' }]): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: _keyVault
  }
]


module accessPolicyResource 'keyVaultAccessPolicy.bicep' = if (AccessPolicies != null) {
  name: 'accessPolicies-${CurrentTime}'
  params: {
    KeyVaultName: _keyVault.name
    AccessPolicies: AccessPolicies ?? []
  }
  dependsOn: []
}

resource _resourceLock 'Microsoft.Authorization/locks@2020-05-01' = if (DeployResourceLock != null) {
  name: DeployResourceLock.?name ?? '${_keyVault.name}lock'
  scope: _keyVault
  properties: {
    level: DeployResourceLock.?kind ?? 'CanNotDelete'
    notes: DeployResourceLock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
}

// ==================================================================================================

// Output Section
output keyVaultUrl string = _keyVault.properties.vaultUri
output keyVaultId string = _keyVault.id
output keyVaultName string = _keyVault.name

// ==================================================================================================

// Type Section

@description('Type for the diagnosticLoggerDestinations parameter')
type diagnosticSettingType = {
  @description('Optional. The name of diagnostic setting.')
  name: string?

  @description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to `[]` to disable log collection.')
  logCategoriesAndGroups: {
    @description('Optional. Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.')
    category: string?

    @description('Optional. Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs.')
    categoryGroup: string?

    @description('Optional. Enable or disable the category explicitly. Default is `true`.')
    enabled: bool?
  }[]?

  @description('Optional. The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.')
  metricCategories: {
    @description('Required. Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
    category: string

    @description('Optional. Enable or disable the category explicitly. Default is `true`.')
    enabled: bool?
  }[]?

  @description('Optional. A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('Optional. The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}


@description('Type for the accessPolicies parameter')
type accessPoliciesType = {
  @description('The tenant ID that is used for authenticating requests to the key vault.')
  tenantId: string?

  @description('The object ID of a user, service principal or security group in the tenant for the vault.')
  objectId: string

  @description('Application ID of the client making request on behalf of a principal.')
  applicationId: string?

  @description('Permissions the identity has for keys, secrets and certificates.')
  permissions: {
    @description('Permissions to keys.')
    keys: (
      | 'all'
      | 'backup'
      | 'create'
      | 'decrypt'
      | 'delete'
      | 'encrypt'
      | 'get'
      | 'getrotationpolicy'
      | 'import'
      | 'list'
      | 'purge'
      | 'recover'
      | 'release'
      | 'restore'
      | 'rotate'
      | 'setrotationpolicy'
      | 'sign'
      | 'unwrapKey'
      | 'update'
      | 'verify'
      | 'wrapKey')[]?

    @description('Permissions to secrets.')
    secrets: (
      | 'all'
      | 'backup'
      | 'delete'
      | 'get'
      | 'list'
      | 'purge'
      | 'recover'
      | 'restore'
      | 'set')[]?

    @description('Permissions to certificates.')
    certificates: (
      | 'all'
      | 'backup'
      | 'create'
      | 'delete'
      | 'deleteissuers'
      | 'get'
      | 'getissuers'
      | 'import'
      | 'list'
      | 'listissuers'
      | 'managecontacts'
      | 'manageissuers'
      | 'purge'
      | 'recover'
      | 'restore'
      | 'setissuers'
      | 'update')[]?

    @description('Permissions to storage accounts.')
    storage: (
      | 'all'
      | 'backup'
      | 'delete'
      | 'deletesas'
      | 'get'
      | 'getsas'
      | 'list'
      | 'listsas'
      | 'purge'
      | 'recover'
      | 'regeneratekey'
      | 'restore'
      | 'set'
      | 'setsas'
      | 'update')[]?
  }
}

@description('Virtual Network Rule Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#virtualnetworkrule')
type virtualNetworkRuleType = {
  @description('The name of the vnet')
  vnetName: string

  @description('The name of the subnet')
  subnetName: string

  @description('The resource group name of the subnet')
  resourceGroupName: string?

  @description('The subscription ID of the subnet')
  subscriptionId: string?

  @description('Ignore missing Vnet Service Endpoint')
  ignoreMissingVnetServiceEndpoint: bool
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
