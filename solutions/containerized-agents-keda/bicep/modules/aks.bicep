param Name string
param Location string
param Identity resourceIdentifier
param Subnet subnetIdentifier
param OutboundType string = 'userAssignedNATGateway'
param DisableOutboundNat bool = true
param KeyVault resourceIdentifier
param CurrentTime string = utcNow('yyyyMMdd-HHmmss')

param AgentSize string = 'Standard_D2S_v5' //Standard_DS2_v2

param SyslogLevels array
param SyslogFacilities array
@allowed([
  'Off'
  'Include'
  'Exclude'
])
param NamespaceFilteringModeForDataCollection string = 'Off'
param DataCollectionInterval string
param NamespacesForDataCollection array
param Streams array = [
  'Microsoft-ContainerInsights-Group-Default'
]
param EnableContainerLogV2 bool
param WorkspaceResourceId string


var dcrName = '${Name}-dcr'
var dataCollectionRuleId = resourceId(split(_aksMonitoringMsiDcr.?id, '/')[2] ?? subscription().subscriptionId, split(_aksMonitoringMsiDcr.?id, '/')[4] ?? resourceGroup().name, 'Microsoft.Insights/dataCollectionRules', dcrName)

#disable-next-line BCP081 // Valid API Version
resource _subnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' existing = {
  name: '${Subnet.vNetName}/${Subnet.subnetName}'
  scope: resourceGroup(Subnet.?subscriptionId ?? subscription().subscriptionId, Subnet.?resourceGroupName ?? resourceGroup().name)
}

resource _identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: Identity.name
}

#disable-next-line BCP081 // Valid API Version
resource _aks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  dependsOn: [
     _subnet
  ]
  name: Name
  location: Location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${_identity.id}': {}
    }
  }
  properties: {
    dnsPrefix: 'aksCluster'
    networkProfile: {
      networkPlugin: 'azure'
      outboundType: OutboundType
    }
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        osType: 'Linux'
        vmSize: AgentSize
        mode: 'System'
        vnetSubnetID: resourceId(Subnet.?subscriptionId ?? subscription().subscriptionId, Subnet.?resourceGroupName ?? resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', Subnet.?vNetName ?? 'vnet', Subnet.?subnetName ?? 'default')
      }
      {
        name: 'linos'
        count: 1
        osType: 'Linux'
        vmSize: AgentSize
        mode: 'User'
        nodeTaints: [
          'os=linux:NoSchedule'
        ]
        vnetSubnetID: resourceId(Subnet.?subscriptionId ?? subscription().subscriptionId, Subnet.?resourceGroupName ?? resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', Subnet.?vNetName ?? 'vnet', Subnet.?subnetName ?? 'default')
      }
      {
        name: 'winos'
        count: 1
        osType: 'Windows'
        vmSize: AgentSize
        mode: 'User'
        nodeTaints: [
          'os=windows:NoSchedule'
        ]
        windowsProfile: {
          disableOutboundNat: DisableOutboundNat
        }
        vnetSubnetID: resourceId(Subnet.?subscriptionId ?? subscription().subscriptionId, Subnet.?resourceGroupName ?? resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', Subnet.?vNetName ?? 'vnet', Subnet.?subnetName ?? 'default')
      }
    ]
    workloadAutoScalerProfile: {
      keda: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    addonProfiles: {
      azurePolicy: {
        enabled: true
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: WorkspaceResourceId
          useAADAuth: 'true'
        }
      }
    }
  }
}

module uamiPermissions 'keyvaultAccessPolicy.bicep' = {
  scope: resourceGroup(KeyVault.?subscriptionId ?? subscription().subscriptionId, KeyVault.?resourceGroupName ?? resourceGroup().name)
  name: 'keyvaultAccessPolicy-secrets-${uniqueString(CurrentTime)}'
  params: {
    keyVaultName: KeyVault.name
    accessPolicies: [
      {
        objectId: _aks.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
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

#disable-next-line BCP081 // Valid API Version
resource _aksMonitoringMsiDcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: dcrName
  location: Location
  kind: 'Linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${_identity.id}': {}
    }
  }
  properties: {
    dataSources: {
      syslog: [
        {
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: SyslogFacilities
          logLevels: SyslogLevels
          name: 'sysLogsDataSource'
        }
      ]
      extensions: [
        {
          name: 'ContainerInsightsExtension'
          streams: Streams
          extensionSettings: {
            dataCollectionSettings: {
              interval: DataCollectionInterval
              namespaceFilteringMode: NamespaceFilteringModeForDataCollection
              namespaces: NamespacesForDataCollection
              enableContainerLogV2: EnableContainerLogV2
            }
          }
          extensionName: 'ContainerInsights'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: WorkspaceResourceId
          name: 'ciworkspace'
        }
      ]
    }
    dataFlows: [
      {
        streams: Streams
        destinations: [
          'ciworkspace'
        ]
      }
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          'ciworkspace'
        ]
      }
    ]
  }
}

/*
resource MSCI_usgovvirginia_eba_keda 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  location: 'usgovvirginia'
  name: 'MSCI-usgovvirginia-eba-keda'
  kind: 'Linux'
  properties: {
    dataSources: {
      extensions: [
        {
          name: 'ContainerInsightsExtension'
          streams: [
            'Microsoft-ContainerInsights-Group-Default'
          ]
          extensionName: 'ContainerInsights'
          extensionSettings: {
            dataCollectionSettings: {
              interval: '1m'
              namespaceFilteringMode: 'Off'
              enableContainerLogV2: true
            }
          }
        }
      ]
      syslog: []
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourcegroups/ephemeralbuildagents/providers/microsoft.operationalinsights/workspaces/w7qtvohgm3zrq'
          name: 'ciworkspace'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-ContainerInsights-Group-Default'
        ]
        destinations: [
          'ciworkspace'
        ]
      }
    ]
  }
}
*/

#disable-next-line BCP174
resource _aksMonitoringMsiDcra 'Microsoft.ContainerService/managedClusters/providers/dataCollectionRuleAssociations@2022-06-01' = {
  dependsOn: [
    _aks
  ]
  name: '${Name}/microsoft.insights/${dcrName}-assoc'
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
    dataCollectionRuleId: dataCollectionRuleId
  }
}

/*
resource ContainerInsightsExtension 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  scope: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourcegroups/ephemeralbuildagents/providers/microsoft.containerservice/managedclusters/eba-keda'
  name: 'ContainerInsightsExtension'
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
    dataCollectionRuleId: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourceGroups/ephemeralbuildagents/providers/Microsoft.Insights/dataCollectionRules/MSCI-usgovvirginia-eba-keda'
  }
}
*/


output aksKubeletIdentity string = _aks.properties.identityProfile.kubeletidentity.objectId
output aksKeyVaultIdentity string = _aks. properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
output nodeResourceGroup string = _aks.properties.nodeResourceGroup
output aksName string = _aks.name

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

/*
resource eba_keda 'Microsoft.ContainerService/ManagedClusters@2023-04-01' = {
  location: 'usgovvirginia'
  name: 'eba-keda'
  tags: {
    AppName: 'EBA'
    CostCenter: 'TBD'
    Customer: 'DT/EI/IM/CVS'
    Environment: 'sbx'
    Requestor: 'doylenj@state.gov'
  }
  properties: {
    provisioningState: 'Succeeded'
    powerState: {
      code: 'Running'
    }
    kubernetesVersion: '1.29'
    currentKubernetesVersion: '1.29.7'
    dnsPrefix: 'aksCluster'
    fqdn: 'akscluster-0xgklrdq.hcp.usgovvirginia.cx.aks.containerservice.azure.us'
    azurePortalFQDN: 'akscluster-0xgklrdq.portal.hcp.usgovvirginia.cx.aks.containerservice.azure.us'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        vmSize: 'Standard_D2S_v5'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourceGroups/ephemeralBuildAgents/providers/Microsoft.Network/virtualNetworks/eba/subnets/default'
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: false
        provisioningState: 'Succeeded'
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: '1.29'
        currentOrchestratorVersion: '1.29.7'
        enableNodePublicIP: false
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        nodeImageVersion: 'AKSUbuntu-2204gen2containerd-202408.27.0'
        upgradeSettings: {
          maxSurge: '10%'
        }
        enableFIPS: false
      }
      {
        name: 'linos'
        count: 1
        vmSize: 'Standard_D2S_v5'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourceGroups/ephemeralBuildAgents/providers/Microsoft.Network/virtualNetworks/eba/subnets/default'
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: false
        provisioningState: 'Succeeded'
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: '1.29'
        currentOrchestratorVersion: '1.29.7'
        enableNodePublicIP: false
        nodeTaints: [
          'os=linux:NoSchedule'
        ]
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        nodeImageVersion: 'AKSUbuntu-2204gen2containerd-202408.27.0'
        upgradeSettings: {
          maxSurge: '10%'
        }
        enableFIPS: false
      }
      {
        name: 'winos'
        count: 1
        vmSize: 'Standard_D2S_v5'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourceGroups/ephemeralBuildAgents/providers/Microsoft.Network/virtualNetworks/eba/subnets/default'
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: false
        provisioningState: 'Succeeded'
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: '1.29'
        currentOrchestratorVersion: '1.29.7'
        enableNodePublicIP: false
        nodeTaints: [
          'os=windows:NoSchedule'
        ]
        mode: 'User'
        osType: 'Windows'
        osSKU: 'Windows2022'
        nodeImageVersion: 'AKSWindows-2022-containerd-20348.2700.240911'
        upgradeSettings: {
          maxSurge: '10%'
        }
        enableFIPS: false
      }
    ]
    windowsProfile: {
      adminUsername: 'azureuser'
      enableCSIProxy: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    nodeResourceGroup: 'MC_ephemeralBuildAgents_eba-keda_usgovvirginia'
    enableRBAC: true
    supportPlan: 'KubernetesOfficial'
    networkProfile: {
      networkPlugin: 'azure'
      networkDataplane: 'azure'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {}
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      outboundType: 'userAssignedNATGateway'
      serviceCidrs: [
        '10.0.0.0/16'
      ]
      ipFamilies: [
        'IPv4'
      ]
    }
    maxAgentPools: 100
    identityProfile: {
      kubeletidentity: {
        resourceId: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourcegroups/MC_ephemeralBuildAgents_eba-keda_usgovvirginia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/eba-keda-agentpool'
        clientId: 'df8d40ad-e95f-4434-9977-42891cffcc04'
        objectId: '7a396a04-f215-4cc5-be81-9218a5ad57cc'
      }
    }
    autoUpgradeProfile: {}
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    storageProfile: {
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: true
      issuerURL: 'https://usgovvirginia.oic.prod-aks.azure.us/4101425f-6ffd-4da7-a124-4cd66e230f1d/4c524e0e-2cf5-4c83-bae2-4c3d89c82ae2/'
    }
    workloadAutoScalerProfile: {
      keda: {
        enabled: true
      }
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourcegroups/ephemeralbuildagents/providers/microsoft.operationalinsights/workspaces/w7qtvohgm3zrq'
          useAADAuth: 'true'
        }
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/c71106df-15ce-4cb6-9a0a-248f86ecd53f/resourceGroups/ephemeralBuildAgents/providers/Microsoft.ManagedIdentity/userAssignedIdentities/eba-keda': {
        clientId: '2132266d-43ca-45d1-aa4d-258a99460b14'
        principalId: '79c06466-9d64-4f04-9e4a-26222506a9c4'
      }
    }
  }
  sku: {
    name: 'Base'
    tier: 'Free'
  }
}
*/
