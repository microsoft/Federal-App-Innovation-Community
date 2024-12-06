param Location string = 'eastus'
param KeyVault resourceIdentifier
param AksName string = 'aks-keda-devops'
param Subnet subnetIdentifier
param Tags object
param SyslogLevels array
param SyslogFacilities array
param Streams array
param DataCollectionInterval string
param NamespaceFilteringModeForDataCollection string = 'Off'
param NamespacesForDataCollection array
param EnableContainerLogV2 bool = true
param AgentSize string = 'Standard_D2S_v5' //Standard_DS2_v2
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')


var baseTag = {
  SourceTemplate: 'SOE-C 2.0'
}
var varTags = union(baseTag, Tags ?? {})
var autoWorkspaceName = take(uniqueString(AksName), 63)


resource _userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: AksName
  location: Location
}

module law 'modules/law.bicep' = {
  name: 'DeployLAW-${uniqueString(CurrentTime)}'
  params: {
    ResourceName: autoWorkspaceName
    Location: Location
    DeployResourceLock: {kind: 'CanNotDelete'}
    IdentityType: 'SystemAssigned'
    Tags: varTags
  }
}

module uamiPermissions 'modules/keyvaultAccessPolicy.bicep' = {
  scope: resourceGroup(KeyVault.?subscriptionId ?? subscription().subscriptionId, KeyVault.?resourceGroupName ?? resourceGroup().name)
  name: 'keyvaultAccessPolicy-${uniqueString(CurrentTime)}'
  params: {
    keyVaultName: KeyVault.name
    accessPolicies: [
      {
        objectId: _userAssignedIdentity.properties.principalId
        tenantId: tenant().tenantId
        permissions: {
            keys: []
            secrets: [
                'get'
                'list'
            ]
            certificates: []
        }
      }
    ]
  }
}


module aksModule 'modules/aks.bicep' = {
  scope: resourceGroup()
  name: 'aksModuleDeployment-${uniqueString(CurrentTime)}'
  params: {
    Location: Location
    Name: AksName
    Identity: {
      name: _userAssignedIdentity.name
    }
    Subnet: Subnet
    WorkspaceResourceId: law.outputs.logAnalyticsWorkspaceId
    SyslogFacilities: SyslogFacilities
    SyslogLevels: SyslogLevels
    Streams: Streams
    DataCollectionInterval: DataCollectionInterval
    NamespaceFilteringModeForDataCollection: NamespaceFilteringModeForDataCollection
    NamespacesForDataCollection: NamespacesForDataCollection
    EnableContainerLogV2: EnableContainerLogV2
    KeyVault: KeyVault
    AgentSize: AgentSize
  }
  dependsOn: [
    uamiPermissions
  ]
}

module acrModule 'modules/acr.bicep' = {
  scope: resourceGroup()
  name: 'acrModuleDeployment-${uniqueString(CurrentTime)}'
  params: {
    location: Location
    kubeletPrincipalId: aksModule.outputs.aksKubeletIdentity
  }
}

output AksName string = aksModule.outputs.aksName

type subnetIdentifier = {
  vNetName: string
  subnetName: string
  resourceGroupName: string?
  subscriptionId: string?
}

type resourceIdentifier = {
  name: string
  resourceGroupName: string?
  subscriptionId: string?
}
