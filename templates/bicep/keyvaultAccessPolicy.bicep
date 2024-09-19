metadata description = 'This is a module and is not meant to be consumed as a primary template'

param KeyVaultName string

param AccessPolicies accessPoliciesType[]

var formattedAccessPolicies = [
  for accessPolicy in (AccessPolicies ?? []): {
    applicationId: accessPolicy.?applicationId ?? '00000000-0000-0000-0000-000000000000'
    objectId: accessPolicy.objectId
    permissions: accessPolicy.permissions
    tenantId: accessPolicy.?tenantId ?? tenant().tenantId
  }
]

resource _keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: KeyVaultName
}

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  parent: _keyVault
  name: 'add'
  properties: {
    accessPolicies: formattedAccessPolicies
  }
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
