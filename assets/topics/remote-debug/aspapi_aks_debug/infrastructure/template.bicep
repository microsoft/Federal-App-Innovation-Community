targetScope = 'resourceGroup'

@description('The name of the Managed Cluster resource.')
param resourceName string = 'AKS-MC-${uniqueString(resourceGroup().id)}'

param storageName string = 'storage${uniqueString(resourceGroup().id)}'

@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'DNS-PREFIX-${uniqueString(resourceGroup().id)}'

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The version of Kubernetes.')
param kubernetesVersion string = '1.7.7'

@description('Network plugin used for building Kubernetes network.')
@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string

@description('Boolean flag to turn on and off of RBAC.')
param enableRBAC bool = true

@description('Enable private network access to the Kubernetes cluster.')
param enablePrivateCluster bool = false

@description('Boolean flag to turn on and off http application routing.')
param enableHttpApplicationRouting bool = true

@description('Boolean flag to turn on and off Azure Policy addon.')
param enableAzurePolicy bool = false

@description('Boolean flag to turn on and off secret store CSI driver.')
param enableSecretStoreCSIDriver bool = false

@description('Specify the name of the Azure Container Registry.')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'


@description('The unique id used in the role assignment of the kubernetes service to the container registry service. It is recommended to use the default value.')
param guidValue string = newGuid()

module ConnectAKStoACR './nested_ConnectAKStoACR.bicep' = {
  name: 'ConnectAKStoACR'
  scope: resourceGroup()
  params: {
    reference_parameters_resourceName_2021_07_01_identityProfile_kubeletidentity_objectId: reference(resourceName, '2021-07-01')
    resourceId_parameters_acrResourceGroup_Microsoft_ContainerRegistry_registries_parameters_acrName: resourceId(resourceGroup().name, 'Microsoft.ContainerRegistry/registries/', acrName)
    acrName: acrName
    guidValue: guidValue
  }
  dependsOn: [
    resourceName_resource
    AcrDeployment
  ]
}

module AcrDeployment './nested_AcrDeployment.bicep' = {
  name: 'AcrDeployment'
  params: {
    name: acrName
    location: location
  }
}

resource resourceName_resource 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: resourceName
  location: location
  tags: {
  }
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: enableRBAC
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: 1
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        vmSize: 'Standard_B2s'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: []
        nodeTaints: []
        enableNodePublicIP: false
        tags: {
        }
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
    }
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: enableHttpApplicationRouting
      }
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      azureKeyvaultSecretsProvider: {
        enabled: enableSecretStoreCSIDriver
      }
    }
  }
  dependsOn: []
}

resource createStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

output controlPlaneFQDN string = resourceName_resource.properties.fqdn
output storageAcctName string = createStorage.name
