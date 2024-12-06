metadata description = 'This is a module and is not meant to be consumed as a primary template'

param keyVaultName string

param accessPolicies array

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: accessPolicies
  }
}
