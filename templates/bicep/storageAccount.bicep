metadata requiredFiles = [
  'keyVaultAddSecret.bicep'
]
metadata name = 'Storage Account'
metadata description = 'Deploys a storage account'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@minLength(3)
@maxLength(24)
@description('The name of the storage account. It must be unique across the entire Azure environment. Format: ^[a-z0-9]*$')
param ResourceName string

@metadata({
  paramType: 'userConfig'
})
@description('The virtual network rules to use for the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#virtualnetworkrule')
param VirtualNetworkRules virtualNetworkRuleType[]?

@metadata({
  paramType: 'userConfig'
})
@description('Whether or not to deploy the storage accounts blob service.')
param DeployBlobService bool

@metadata({
  paramType: 'userConfig'
})
@description('Whether or not to deploy the storage accounts file service.')
param DeployFileService bool

@metadata({
  paramType: 'userConfig'
})
@description('Whether or not to deploy the storage accounts queue service.')
param DeployQueueService bool

@metadata({
  paramType: 'userConfig'
})
@description('Whether or not to deploy the storage accounts table service.')
param DeployTableService bool

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
@description('Whether or not to deploy the resource lock. This requires a custom role added to your deployment service principal.')
param DeployResourceLock lockType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Key vault parameter to upload the primary key')
param KeyVaultPrimaryKeyUpload keyVaultParamType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Key vault parameter to upload the secondary key')
param KeyVaultSecondaryKeyUpload keyVaultParamType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Key vault parameter to upload the primary connection string')
param KeyVaultConnectionStringPrimaryUpload keyVaultParamType?

@metadata({
  paramType: 'optionalConfig'
})
@description('Key vault parameter to upload the secondary connection string')
param KeyVaultConnectionStringSecondaryUpload keyVaultParamType?

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  true
])
@description('Deploy the storage account as a data lake.')
param DeployDataLake bool?

@metadata({
  paramType: 'optionalConfig'
})
@description('Enable NFSv3 on the storage account.')
param IsNfsV3Enabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Enable SFTP on the storage account.')
param IsSftpEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Array of containers to deploy')
param BlobContainers blobContainersType[] = []

@metadata({
  paramType: 'optionalConfig'
})
@description('Array of FileShares to deploy')
param FileShares fileSharesType[] = []

@metadata({
  paramType: 'optionalConfig'
})
@description('Array of Queues to deploy')
param Queues queuesType[] = []

@metadata({
  paramType: 'optionalConfig'
})
@description('Array of Tables to deploy')
param Tables tablesType[] = []

@metadata({
  paramType: 'optionalConfig'
})
@description('Location of the resource.')
param Location string = resourceGroup().location

@metadata({
  paramType: 'optionalConfig'
})
@description('The SKU of the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#sku')
param Sku storageSku = {
  name: 'Standard_GRS'
}

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
@description('The kind of the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#storageaccounts')
param Kind string = 'StorageV2'

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  'Cool'
  'Hot'
  'Premium'
])
@description('The access tier of the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#storageaccountpropertiescreateparametersorstorageacc')
param AccessTier string = 'Hot'

@metadata({
  paramType: 'optionalConfig'
})
@description('Allow shared key access to the storage account.')
param AllowedSharedKeyAccess bool = true

@metadata({
  paramType: 'optionalConfig'
})
@description('The custom domain to use for the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#customdomain')
param CustomDomain customDomain?

@metadata({
  paramType: 'optionalConfig'
})
@description('The default to OAuth authentication to use for the storage account.')
param DefaultToOAuthAuthentication bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The encryption key source to use for encryption.')
param EncryptionKeySource string = 'Microsoft.Storage'

@metadata({
  paramType: 'optionalConfig'
})
@description('The encryption identity to use for encryption when encryptionKeySource is set to Microsoft.KeyVault. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#encryptionidentity')
param EncryptionIdentity object = {}

@metadata({
  paramType: 'optionalConfig'
})
@description('The encryption key vault properties to use for encryption when encryptionKeySource is set to Microsoft.KeyVault. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#keyvaultproperties')
param EncryptionKeyVault object = {}

@metadata({
  paramType: 'optionalConfig'
})
@description('Require infrastructure encryption.')
param RequireInfrastructureEncryption bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The shared access signature policy to use for the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#saspolicy')
param SasPolicy object = {}

@metadata({
  paramType: 'optionalConfig'
})
@description('The list of CORS rules to use for the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobServices?pivots=deployment-language-bicep#cors')
param BlobCors corsRuleType[] = []

@metadata({
  paramType: 'optionalConfig'
})
@description('The automatic snapshot policy to use for the storage account.')
param BlobAutomaticSnapshotPolicyEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The container delete retention policy to use for the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices?pivots=deployment-language-bicep#changefeed')
param BlobChangeFeedEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The retention in days of the change feed. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices?pivots=deployment-language-bicep#changefeed')
param BlobChangeFeedRetentionInDays int = 7

@metadata({
  paramType: 'optionalConfig'
})
@description('The container delete retention policy to use for the storage account.')
param BlobContainerDeleteRetentionPolicyAllowPermanentDelete bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The container delete retention policy days.')
param BlobContainerDeleteRetentionPolicyDays int = 7

@metadata({
  paramType: 'optionalConfig'
})
@description('The container soft delete policy is enabled.')
param BlobEnableContainerSoftDelete bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The default service version to use for the storage account. See: https://learn.microsoft.com/en-us/rest/api/storageservices/versioning-for-the-azure-storage-services')
param BlobDefaultServiceVersion string = '2023-11-03'

@metadata({
  paramType: 'optionalConfig'
})
@description('The delete retention policy to use for the storage account.')
param BlobDeleteRetentionPolicyAllowPermanentDelete bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The delete retention policy days.')
param BlobDeleteRetentionPolicyDays int = 7

@metadata({
  paramType: 'optionalConfig'
})
@description('The delete retention policy is enabled.')
param BlobDeleteRetentionPolicyEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('Enable versioning on the blobs in the storage account.')
param BlobIsVersioningEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The last access time tracking policy to is enabled for the storage account.')
param BlobLastAccessTimeTrackingPolicyEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The tracking granularity in days for the last access time tracking policy.')
param BlobTrackingGranularityInDays int = 7

@metadata({
  paramType: 'optionalConfig'
})
@description('The restore policy to use for the blobs in the storage account.')
param BlobRestorePolicyDays int = 7

@metadata({
  paramType: 'optionalConfig'
})
@description('The restore policy is enabled.')
param BlobRestorePolicyEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('File Share SMB settings')
param FileProtocolSettingsSmb object = {}

@metadata({
  paramType: 'optionalConfig'
})
@description('The share delete retention policy to use for the storage account.')
param FileShareDeleteRetentionPolicyAllowPermanentDelete bool = true

@metadata({
  paramType: 'optionalConfig'
})
@description('The share delete retention policy days.')
param FileShareDeleteRetentionPolicyDays int = 0

@metadata({
  paramType: 'optionalConfig'
})
@description('The share delete retention policy is enabled.')
param FileShareDeleteRetentionPolicyEnabled bool = false

@metadata({
  paramType: 'optionalConfig'
})
@description('The CORS rules to use for the file service.')
param FileCors array = []

@metadata({
  paramType: 'optionalConfig'
})
@description('The queue CORS rules to use for the storage account.')
param QueueCors array = []

@metadata({
  paramType: 'optionalConfig'
})
@description('The table CORS rules to use for the storage account.')
param TableCors array = []

@metadata({
  paramType: 'optionalConfig'
})
@description('Which services can bypass the ACL for the storage account. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#networkruleset')
param NetworkAclBypass string = 'None'

@metadata({
  paramType: 'optionalConfig'
})
@allowed([
  'Enabled'
  'Disabled'
])
@description('''
  The public network access to use for the storage account.
  See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#storageaccountpropertiescreateparametersorstorageacc
''')
param PublicNetworkAccess string = 'Enabled'

@metadata({
  paramType: 'optionalConfig'
})
@description('The large file shares state to use for the storage account.')
param LargeFileSharesState string = 'Disabled'

@metadata({
  paramType: 'optionalConfig'
})
@description('enable the local users feature on the storage account.')
param IsLocalUserEnabled bool = false

//Security Section. Deviations may result in limited or no control inheritance from environment
@metadata({
  paramType: 'securityConfig'
})
@description('The services to enable encryption on.')
param EncryptionServices object = {
  blob: {
    enabled: true
  }
  file: {
    enabled: true
  }
  queue: {
    enabled: true
  }
  table: {
    enabled: true
  }
}

@metadata({
  paramType: 'securityConfig'
})
@description('Blob public access (unauthenticated access) is allowed.')
param AllowBlobPublicAccess bool = false

@metadata({
  paramType: 'securityConfig'
})
@description('Allow cross tenant replication.')
param AllowCrossTenantReplication bool = false

@metadata({
  paramType: 'securityConfig'
})
@description('The allowed copy scope for the storage account for cross tenant replication.')
param AllowedCopyScope string = 'AAD'

@metadata({
  paramType: 'securityConfig'
})
@description('The IP Rules to allow to access the storage account.')
param IpRules array = []

@metadata({
  paramType: 'securityConfig'
})
@description('The default action for the network ACLs. Allow opens to all networking while deny enables the firewall.')
param NetworkDefaultAction string = 'Deny'

@metadata({
  paramType: 'securityConfig'
})
@description('The minimum TLS version to use for the storage account.')
param MinimumTlsVersion string = 'TLS1_2'

@metadata({
  paramType: 'securityConfig'
})
@description('Used to give the deployment a unique name')
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')

// ==================================================================================================

// Variables Section
var san = toLower(ResourceName)
var blobChangeFeed = BlobChangeFeedEnabled
  ? {
      enabled: BlobChangeFeedEnabled
      retentionInDays: BlobChangeFeedRetentionInDays
    }
  : null
var containerDeleteRetentionPolicy = BlobEnableContainerSoftDelete
  ? {
      allowPermanentDelete: BlobContainerDeleteRetentionPolicyAllowPermanentDelete
      days: BlobContainerDeleteRetentionPolicyDays
      enabled: BlobEnableContainerSoftDelete
    }
  : {}
var blobDeleteRetentionPolicy = BlobDeleteRetentionPolicyEnabled
  ? {
      allowPermanentDelete: BlobDeleteRetentionPolicyAllowPermanentDelete
      days: BlobDeleteRetentionPolicyDays
      enabled: BlobDeleteRetentionPolicyEnabled
    }
  : {}
var baseTag = {
  SourceTemplate: 'SOE-C 2.0'
}
var varTags = union(baseTag, Tags)

var processedVirtualNetworkRules = [
  for rule in (VirtualNetworkRules ?? []): {
    id: resourceId(
      rule.SubscriptionId ?? subscription().subscriptionId,
      rule.ResourceGroupName ?? resourceGroup().name,
      'Microsoft.Network/virtualNetworks/subnets',
      rule.VNetName,
      rule.SubnetName
    )
  }
]
// ==================================================================================================

// Resource Section

resource _storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: san
  location: Location
  sku: Sku
  kind: Kind
  tags: varTags
  properties: {
    accessTier: AccessTier
    allowBlobPublicAccess: AllowBlobPublicAccess
    allowCrossTenantReplication: AllowCrossTenantReplication
    allowedCopyScope: AllowedCopyScope
    allowSharedKeyAccess: AllowedSharedKeyAccess
    customDomain: CustomDomain
    defaultToOAuthAuthentication: DefaultToOAuthAuthentication
    encryption: {
      services: EncryptionServices
      keySource: EncryptionKeySource
      keyvaultproperties: EncryptionKeyVault
      identity: EncryptionIdentity
      requireInfrastructureEncryption: RequireInfrastructureEncryption
    }
    isHnsEnabled: DeployDataLake
    isLocalUserEnabled: IsLocalUserEnabled
    isNfsV3Enabled: IsNfsV3Enabled
    isSftpEnabled: IsSftpEnabled
    largeFileSharesState: LargeFileSharesState
    minimumTlsVersion: MinimumTlsVersion
    networkAcls: {
      bypass: NetworkAclBypass
      virtualNetworkRules: processedVirtualNetworkRules
      ipRules: IpRules
      defaultAction: NetworkDefaultAction
    }
    publicNetworkAccess: PublicNetworkAccess
    sasPolicy: SasPolicy
    supportsHttpsTrafficOnly: true
  }
}

resource _blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' =
  if (DeployBlobService) {
    name: 'default'
    parent: _storageAccount
    properties: {
      automaticSnapshotPolicyEnabled: BlobAutomaticSnapshotPolicyEnabled
      changeFeed: blobChangeFeed
      containerDeleteRetentionPolicy: containerDeleteRetentionPolicy
      cors: {
        corsRules: BlobCors
      }
      defaultServiceVersion: BlobDefaultServiceVersion
      deleteRetentionPolicy: blobDeleteRetentionPolicy
      isVersioningEnabled: BlobIsVersioningEnabled
      lastAccessTimeTrackingPolicy: {
        enable: BlobLastAccessTimeTrackingPolicyEnabled
        trackingGranularityInDays: BlobTrackingGranularityInDays
      }
      restorePolicy: {
        days: BlobRestorePolicyDays
        enabled: BlobRestorePolicyEnabled
      }
    }
  }

resource _containerResources 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [
  for (blobContainer, i) in BlobContainers: if (DeployBlobService && length(BlobContainers) > 0) {
    parent: _blobService
    name: blobContainer.name
    properties: blobContainer.properties
  }
]

resource _fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' =
  if (DeployFileService) {
    name: 'default'
    parent: _storageAccount
    properties: {
      cors: {
        corsRules: FileCors
      }
      protocolSettings: {
        smb: FileProtocolSettingsSmb
      }
      shareDeleteRetentionPolicy: {
        allowPermanentDelete: FileShareDeleteRetentionPolicyAllowPermanentDelete
        days: FileShareDeleteRetentionPolicyDays
        enabled: FileShareDeleteRetentionPolicyEnabled
      }
    }
  }

resource _shareResources 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [
  for (share, i) in FileShares: if (DeployFileService && length(FileShares) > 0) {
    parent: _fileService
    name: share.name
    properties: share.properties
  }
]

resource _queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' =
  if (DeployQueueService) {
    name: 'default'
    parent: _storageAccount
    properties: {
      cors: {
        corsRules: QueueCors
      }
    }
  }

resource _queueResources 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = [
  for (queue, i) in Queues: if (DeployQueueService && length(Queues) > 0) {
    parent: _queueService
    name: queue.name
    properties: queue.properties
  }
]

resource _tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' =
  if (DeployTableService) {
    name: 'default'
    parent: _storageAccount
    properties: {
      cors: {
        corsRules: TableCors
      }
    }
  }

resource _tableResources 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = [
  for (table, i) in Tables: if (DeployTableService && length(Tables) > 0) {
    parent: _tableService
    name: table.name
  }
]

module keyVaultSecretPrimary 'keyVaultAddSecret.bicep' = if (KeyVaultPrimaryKeyUpload != null) {
  name: 'DeployKeyVaultSecret-${uniqueString(CurrentTime)}SP'
  scope: resourceGroup(KeyVaultPrimaryKeyUpload.?subscriptionId ?? subscription().subscriptionId, KeyVaultPrimaryKeyUpload.?resourceGroupName ?? resourceGroup().name)
  params: {
    SecretName: KeyVaultPrimaryKeyUpload.?secretName ?? '${_storageAccount.name}PrimaryKey'
    KeyVaultName: KeyVaultPrimaryKeyUpload.?keyVaultName ?? ''
    Enabled: true
    SecretValue: _storageAccount.listKeys().keys[0].value
  }
  dependsOn: []
}

module keyVaultSecretSecondary 'keyVaultAddSecret.bicep' = if (KeyVaultSecondaryKeyUpload != null) {
  name: 'DeployKeyVaultSecret-${uniqueString(CurrentTime)}SS'
  scope: resourceGroup(KeyVaultSecondaryKeyUpload.?subscriptionId ?? subscription().subscriptionId, KeyVaultSecondaryKeyUpload.?resourceGroupName ?? resourceGroup().name)
  params: {
    SecretName: KeyVaultSecondaryKeyUpload.?secretName ?? '${_storageAccount.name}SecondaryKey'
    KeyVaultName: KeyVaultSecondaryKeyUpload.?keyVaultName ?? ''
    Enabled: true
    SecretValue: _storageAccount.listKeys().keys[1].value
  }
  dependsOn: []
}

module keyVaultConnectionStringPrimary 'keyVaultAddSecret.bicep' = if (KeyVaultConnectionStringPrimaryUpload != null) {
  name: 'DeployKeyVaultSecret-${uniqueString(CurrentTime)}CSP'
  scope: resourceGroup(KeyVaultConnectionStringPrimaryUpload.?subscriptionId ?? subscription().subscriptionId, KeyVaultConnectionStringPrimaryUpload.?resourceGroupName ?? resourceGroup().name)
  params: {
    SecretName: KeyVaultConnectionStringPrimaryUpload.?secretName ?? '${_storageAccount.name}StorageAccountConnectionString'
    KeyVaultName: KeyVaultConnectionStringPrimaryUpload.?keyVaultName ?? ''
    Enabled: true
    SecretValue: 'DefaultEndpointsProtocol=https;AccountName=${_storageAccount.name};AccountKey=${_storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
  dependsOn: []
}

module keyVaultConnectionStringSecondary 'keyVaultAddSecret.bicep' = if (KeyVaultConnectionStringSecondaryUpload != null) {
  name: 'DeployKeyVaultSecret-${uniqueString(CurrentTime)}CSS'
  scope: resourceGroup(KeyVaultConnectionStringSecondaryUpload.?subscriptionId ?? subscription().subscriptionId, KeyVaultConnectionStringSecondaryUpload.?resourceGroupName ?? resourceGroup().name)
  params: {
    SecretName: KeyVaultConnectionStringSecondaryUpload.?secretName ?? '${_storageAccount.name}StorageAccountConnectionString'
    KeyVaultName: KeyVaultConnectionStringSecondaryUpload.?keyVaultName ?? ''
    Enabled: true
    SecretValue: 'DefaultEndpointsProtocol=https;AccountName=${_storageAccount.name};AccountKey=${_storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
  dependsOn: []
}

resource _resourceLock 'Microsoft.Authorization/locks@2020-05-01' = if (DeployResourceLock != null) {
  name: DeployResourceLock.?name ?? '${_storageAccount.name}lock'
  scope: _storageAccount
  properties: {
    level: DeployResourceLock.?kind ?? 'CanNotDelete'
    notes: DeployResourceLock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
}

// ==================================================================================================

// Output Section
output storageAccountName string = _storageAccount.name
output storageAccountResourceId string = _storageAccount.id

// ==================================================================================================

// Type Section
type customDomain = {
  @description('The custom domain name. Name is the CNAME source.')
  name: string

  @description('Indicates whether indirect CName validation is enabled. Default value is false.')
  useSubDomainName: bool?
}

type storageSku = {
  @description('The name of the SKU')
  name: 'Premium_LRS'
    | 'Premium_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_LRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'Standard_ZRS'
}
@description('Virtual Network Rule Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep#virtualnetworkrule')
type virtualNetworkRuleType = {
  @description('The name of the virtual network')
  vNetName: string

  @description('The name of the subnet')
  subnetName: string

  @description('Resource Group Name of the virtual network')
  resourceGroupName: string?

  @description('Subscription ID of the virtual network')
  subscriptionId: string?
}

@description('Blob Container Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobServices/containers?pivots=deployment-language-bicep')
type blobContainersType = {
  @description('The name of the container')
  name: string

  @description('The properties of the container')
  properties: {
    
    @description('The access tier of the container')
    publicAccess: 'Blob' | 'Container' | 'None'
    

    @description('Metadata for the container')
    metadata: {
      *: string
    }?

    @description('Whether or not to enable immutability on the container')
    immutableStorageWithVersioning: {
      enabled: bool
    }?

    @description('Prevent encryption scope overrides on the container')
    denyEncryptionScopeOverride: bool?

    @description('Enable NfsV3 All Squash')
    enableNfsV3AllSquash: bool?

    @description('Enable NfsV3 Root Squash')
    enableNfsV3RootSquash: bool?
  }
}

@description('File Share Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileServices/shares?pivots=deployment-language-bicep')
type fileSharesType = {
  @description('The name of the file share')
  name: string
  @description('The properties of the file share')
  properties: {

    @description('The access tier of the file share')
    accessTier: 'Cool' | 'Hot' | 'TransactionOptimized' | 'Premium'

    @description('The enabled protocols of the file share')
    enabledProtocols: 'SMB' | 'NFS' | 'None' | null

    @description('The enabled rootSquash of the file share')
    rootSquash: 'NoRootSquash' | 'RootSquash' | 'AllSquash' | 'None' | null

    @description('Metadata for the file share')
    metadata: {
      *: string
    }?

    @minValue(1)
    @maxValue(102400)
    @description('The quota of the file share')
    shareQuota: int
  }
}

@description('Queue Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/queueServices/queues?pivots=deployment-language-bicep')
type queuesType = {
  @description('The name of the queue')
  name: string

  @description('The properties of the queue')
  properties: {

    @description('Metadata for the queue')
    metadata: {
      *: string
    }?
  }?
}

@description('Table Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices/tables?pivots=deployment-language-bicep')
type tablesType = {
  @description('The name of the table')
  name: string
}

@description('CORS Rule Type. See: https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices?pivots=deployment-language-bicep#corsrule')
type corsRuleType = {
  @description('The allowed headers')
  allowedHeaders: string[]

  @description('The allowed methods')
  allowedMethods: string[]

  @description('The allowed origins')
  allowedOrigins: string[]

  @description('The exposed headers')
  exposedHeaders: string[]

  @description('The max age in seconds')
  maxAgeInSeconds: int
}

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
}?

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
