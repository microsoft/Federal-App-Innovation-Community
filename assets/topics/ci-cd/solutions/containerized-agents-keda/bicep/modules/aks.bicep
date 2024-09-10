param name string
param location string

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'aksCluster'
    networkProfile: {
      networkPlugin: 'azure'
    }
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        osType: 'Linux'
        vmSize: 'Standard_D2S_v5'
        mode: 'System'
      }
      {
        name: 'linos'
        count: 1
        osType: 'Linux'
        vmSize: 'Standard_D2S_v5'
        mode: 'User'
        nodeTaints: [
          'os=linux:NoSchedule'
        ]
      }
      {
        name: 'winos'
        count: 1
        osType: 'Windows'
        vmSize: 'Standard_D2S_v5'
        mode: 'User'
        nodeTaints: [
          'os=windows:NoSchedule'
        ]
      }
    ]
    workloadAutoScalerProfile: {
      keda: {
        enabled: true
      }
    }
  }
}

output aksKubeletIdentity string = aks.properties.identityProfile.kubeletidentity.objectId
