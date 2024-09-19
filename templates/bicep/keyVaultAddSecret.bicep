metadata description = 'This is a module and is not meant to be consumed as a primary template'

param SecretName string

param KeyVaultName string

@secure()
param SecretValue string

param Tags object = {}

param Enabled bool = true

@description('Expiry date in seconds since 1970-01-01T00:00:00Z.')
param Expiration int = 0

@description('Not before date in seconds since 1970-01-01T00:00:00Z.')
param NotBefore int = 0

param ContentType string = ''

var nbf = NotBefore == 0 ? null : NotBefore
var exp = Expiration == 0 ? null : Expiration

resource _keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: KeyVaultName
}

resource addSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: SecretName
  tags: Tags
  parent: _keyVault
  properties: {
    attributes: {
      enabled: Enabled
      exp: exp
      nbf: nbf
    }
    contentType: ContentType
    value: SecretValue
  }
}
