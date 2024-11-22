metadata requiredFiles = []
metadata name = 'Private Endpoint'
metadata description = 'This template creates a private endpoint configuration output rather than a resource'
metadata version = '2.6.0'
metadata referenceUrl = 'https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#government'

// User Config Section: expected to be filled out by deployment team
@metadata({
  paramType: 'userConfig'
})
@description('Array of Configuration details for the private endpoints.')
param PrivateEndpointConfigs privateEndpointConfigType[]

// Optional Parameters Section: optional for configuration
//Security Section. Deviations may result in limited or no control inheritance from environment

// ==================================================================================================

// Variables Section
var resourceTypes = {
  'Azure AI services': {
    type: 'Microsoft.CognitiveServices/accounts'
    subresources: [
      {
        type: 'account'
        dnsZones: ['privatelink.cognitiveservices.azure.us']
        publicDnsForwarders: ['cognitiveservices.azure.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/search/service-create-private-endpoint'
  }
  'Azure Machine Learning': {
    type: 'Microsoft.MachineLearningServices/workspaces'
    subresources: [
      {
        type: 'amlworkspace'
        dnsZones: ['privatelink.api.ml.azure.us', 'privatelink.notebooks.usgovcloudapi.net']
        publicDnsForwarders: ['api.ml.azure.us', 'notebooks.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/machine-learning/how-to-configure-private-link?view=azureml-api-2&tabs=cli'
  }
  'Azure Event Hubs': {
    type: 'Microsoft.EventHub/namespaces'
    subresources: [
      {
        type: 'namespace'
        dnsZones: ['privatelink.servicebus.usgovcloudapi.net']
        publicDnsForwarders: ['servicebus.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/event-hubs/private-link-service'
  }
  'Azure Synapse Analytics': {
    type: 'Microsoft.Synapse/workspaces'
    subresources: [
      {
        type: 'Sql'
        dnsZones: ['privatelink.sql.azuresynapse.usgovcloudapi.net']
        publicDnsForwarders: ['sql.azuresynapse.usgovcloudapi.net']
      }
      {
        type: 'SqlOnDemand'
        dnsZones: ['privatelink.sql.azuresynapse.usgovcloudapi.net']
        publicDnsForwarders: ['{workspaceName}-ondemand.sql.azuresynapse.usgovcloudapi.net']
      }
      {
        type: 'Dev'
        dnsZones: ['privatelink.dev.azuresynapse.usgovcloudapi.net']
        publicDnsForwarders: ['dev.azuresynapse.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/synapse-analytics/security/how-to-connect-to-workspace-with-private-links'
  }
  'Azure Synapse Studio': {
    type: 'Microsoft.Synapse/privateLinkHubs'
    subresources: [
      {
        type: 'Web'
        dnsZones: ['privatelink.azuresynapse.usgovcloudapi.net']
        publicDnsForwarders: ['azuresynapse.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/synapse-analytics/security/synapse-private-link-hubs'
  }
  'Azure Data Factory': {
    type: 'Microsoft.DataFactory/factories'
    subresources: [
      {
        type: 'dataFactory'
        dnsZones: ['privatelink.datafactory.azure.us']
        publicDnsForwarders: ['datafactory.azure.us']
      }
      {
        type: 'portal'
        dnsZones: ['privatelink.adf.azure.us']
        publicDnsForwarders: ['adf.azure.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/data-factory/data-factory-private-link'
  }
  'Azure SQL Database': {
    type: 'Microsoft.Sql/servers'
    subresources: [
      {
        type: 'sqlServer'
        dnsZones: ['privatelink.database.usgovcloudapi.net']
        publicDnsForwarders: ['database.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview?view=azuresql'
  }
  'Azure Cosmos DB': {
    type: 'Microsoft.DocumentDB/databaseAccounts'
    subresources: [
      {
        type: 'Sql'
        dnsZones: ['privatelink.documents.azure.us']
        publicDnsForwarders: ['documents.azure.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-private-endpoints?tabs=arm-bicep'
  }
  'Azure Service Bus': {
    type: 'Microsoft.ServiceBus/namespaces'
    subresources: [
      {
        type: 'namespace'
        dnsZones: ['privatelink.servicebus.usgovcloudapi.net']
        publicDnsForwarders: ['servicebus.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/service-bus-messaging/private-link-service'
  }
  'Azure Automation': {
    type: 'Microsoft.Automation/automationAccounts'
    subresources: [
      {
        type: 'Webhook'
        dnsZones: ['privatelink.azure-automation.us']
        publicDnsForwarders: ['azure-automation.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/automation/how-to/private-link-security'
  }
  'Azure Monitor': {
    type: 'Microsoft.Insights/privateLinkScopes'
    subresources: [
      {
        type: 'azuremonitor'
        dnsZones: [
          'privatelink.monitor.azure.us'
          'privatelink.adx.monitor.azure.us'
          'privatelink.oms.opinsights.azure.us'
          'privatelink.ods.opinsights.azure.us'
          'privatelink.agentsvc.azure-automation.us'
          'privatelink.blob.core.usgovcloudapi.net'
        ]
        publicDnsForwarders: [
          'monitor.azure.us'
          'adx.monitor.azure.us'
          'oms.opinsights.azure.us'
          'ods.opinsights.azure.us'
          'agentsvc.azure-automation.us'
          'blob.core.usgovcloudapi.net'
        ]
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security'
  }
  'Microsoft Purview': {
    type: 'Microsoft.Purview'
    subresources: [
      {
        type: 'account'
        dnsZones: ['privatelink.purview.azure.us']
        publicDnsForwarders: ['purview.azure.us']
      }
      {
        type: 'portal'
        dnsZones: ['privatelink.purviewstudio.azure.us']
        publicDnsForwarders: ['purviewstudio.azure.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/purview/catalog-private-link'
  }
  'Azure Key Vault': {
    type: 'Microsoft.KeyVault/vaults'
    subresources: [
      {
        type: 'vault'
        dnsZones: ['privatelink.vaultcore.usgovcloudapi.net']
        publicDnsForwarders: ['vaultcore.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service?tabs=portal'
  }
  'Azure App Configuration': {
    type: 'Microsoft.AppConfiguration/configurationStores'
    subresources: [
      {
        type: 'configurationStores'
        dnsZones: ['privatelink.azconfig.azure.us']
        publicDnsForwarders: ['azconfig.azure.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/azure-app-configuration/concept-private-endpoint'
  }
  'Storage account - Blob': {
    type: 'Microsoft.Storage/storageAccounts'
    subresources: [
      {
        type: 'blob'
        dnsZones: ['privatelink.blob.core.usgovcloudapi.net']
        publicDnsForwarders: ['blob.core.usgovcloudapi.net']
      }
      {
        type: 'blob_secondary'
        dnsZones: ['privatelink.blob.core.usgovcloudapi.net']
        publicDnsForwarders: ['blob.core.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints'
  }
  'Storage account - Table': {
    type: 'Microsoft.Storage/storageAccounts'
    subresources: [
      {
        type: 'table'
        dnsZones: ['privatelink.table.core.usgovcloudapi.net']
        publicDnsForwarders: ['table.core.usgovcloudapi.net']
      }
      {
        type: 'table_secondary'
        dnsZones: ['privatelink.table.core.usgovcloudapi.net']
        publicDnsForwarders: ['table.core.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints'
  }
  'Storage account - Queue': {
    type: 'Microsoft.Storage/storageAccounts'
    subresources: [
      {
        type: 'queue'
        dnsZones: ['privatelink.queue.core.usgovcloudapi.net']
        publicDnsForwarders: ['queue.core.usgovcloudapi.net']
      }
      {
        type: 'queue_secondary'
        dnsZones: ['privatelink.queue.core.usgovcloudapi.net']
        publicDnsForwarders: ['queue.core.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints'
  }
  'Storage account - File': {
    type: 'Microsoft.Storage/storageAccounts'
    subresources: [
      {
        type: 'file'
        dnsZones: ['privatelink.file.core.usgovcloudapi.net']
        publicDnsForwarders: ['file.core.usgovcloudapi.net']
      }
      {
        type: 'file_secondary'
        dnsZones: ['privatelink.file.core.usgovcloudapi.net']
        publicDnsForwarders: ['file.core.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints'
  }
  'Storage account - Web': {
    type: 'Microsoft.Storage/storageAccounts'
    subresources: [
      {
        type: 'web'
        dnsZones: ['privatelink.web.core.usgovcloudapi.net']
        publicDnsForwarders: ['web.core.usgovcloudapi.net']
      }
      {
        type: 'web_secondary'
        dnsZones: ['privatelink.web.core.usgovcloudapi.net']
        publicDnsForwarders: ['web.core.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints'
  }
  'Azure Data Lake File System Gen2': {
    type: 'Microsoft.Storage/storageAccounts'
    subresources: [
      {
        type: 'dfs'
        dnsZones: ['privatelink.dfs.core.usgovcloudapi.net']
        publicDnsForwarders: ['dfs.core.usgovcloudapi.net']
      }
      {
        type: 'dfs_secondary'
        dnsZones: ['privatelink.dfs.core.usgovcloudapi.net']
        publicDnsForwarders: ['dfs.core.usgovcloudapi.net']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints'
  }
  'Azure Search': {
    type: 'Microsoft.Search/searchServices'
    subresources: [
      {
        type: 'searchService'
        dnsZones: ['privatelink.search.azure.us']
        publicDnsForwarders: ['search.azure.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/search/service-create-private-endpoint'
  }
  'Azure Web Apps': {
    type: 'Microsoft.Web/sites'
    subresources: [
      {
        type: 'sites'
        dnsZones: ['privatelink.azurewebsites.us']
        publicDnsForwarders: ['azurewebsites.us']
      }
      {
        type: 'sites'
        dnsZones: ['scm.privatelink.azurewebsites.us']
        publicDnsForwarders: ['scm.azurewebsites.us']
      }
    ]
    url: 'https://learn.microsoft.com/en-us/azure/app-service/overview-private-endpoint'
  }
}
var totalConfigs = length(PrivateEndpointConfigs)

var resourceTypeMapping = {
  'Azure AI services': 'Microsoft.CognitiveServices/accounts'
  'Azure Machine Learning': 'Microsoft.MachineLearningServices/workspaces'
  'Azure Event Hubs': 'Microsoft.EventHub/namespaces'
  'Azure Synapse Analytics': 'Microsoft.Synapse/workspaces'
  'Azure Synapse Studio': 'Microsoft.Synapse/privateLinkHubs'
  'Azure Data Factory': 'Microsoft.DataFactory/factories'
  'Azure SQL Database': 'Microsoft.Sql/servers'
  'Azure Cosmos DB': 'Microsoft.DocumentDB/databaseAccounts'
  'Azure Service Bus': 'Microsoft.ServiceBus/namespaces'
  'Azure Automation': 'Microsoft.Automation/automationAccounts'
  'Azure Monitor': 'Microsoft.Insights/privateLinkScopes'
  'Microsoft Purview': 'Microsoft.Purview/accounts'
  'Azure Key Vault': 'Microsoft.KeyVault/vaults'
  'Azure App Configuration': 'Microsoft.AppConfiguration/configurationStores'
  'Storage account - Blob': 'Microsoft.Storage/storageAccounts'
  'Storage account - Table': 'Microsoft.Storage/storageAccounts'
  'Storage account - Queue': 'Microsoft.Storage/storageAccounts'
  'Storage account - File': 'Microsoft.Storage/storageAccounts'
  'Storage account - Web': 'Microsoft.Storage/storageAccounts'
  'Azure Data Lake File System Gen2': 'Microsoft.Storage/storageAccounts'
  'Azure Search': 'Microsoft.Search/searchServices'
  'Azure Web Apps': 'Microsoft.Web/sites'
}

var resourceInfos = map(PrivateEndpointConfigs, (config, i) => {
    index: i
    primaryLinkType: first(config.privateLinkTypes)
    name: config.targetResource.name
    resourceGroup: config.targetResource.resourceGroupName ?? 'N/A'
    subscriptionId: config.targetResource.subscriptionId ?? 'N/A'
    resourceId: resourceId(
      config.targetResource.subscriptionId ?? subscription().subscriptionId,
      config.targetResource.resourceGroupName ?? resourceGroup().name,
      #disable-next-line BCP321 // The resource type is a valid key in the resourceTypes object
      resourceTypeMapping[first(config.privateLinkTypes)],
      config.targetResource.name
  )
  #disable-next-line BCP321 // The resource type is a valid key in the resourceTypes object
  url: resourceTypes[first(config.privateLinkTypes)].url
})

var subnetInfos = map(PrivateEndpointConfigs, config => {
  name: config.subnet.name
  vnetName: config.subnet.vnetName
  resourceGroup: config.subnet.resourceGroupName
  subscriptionId: config.subnet.subscriptionId ?? 'N/A'
  subnetId: resourceId(config.subnet.subscriptionId ?? subscription().subscriptionId, config.subnet.resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', config.subnet.vnetName, config.subnet.name)
})

var flattenedConfigs = flatten(map(PrivateEndpointConfigs, (config) => 
  flatten(map(config.privateLinkTypes, (linkType, linkIndex) => 
    map(resourceTypes[linkType].subresources, (subresource, subIndex) => {
      config: config
      linkType: linkType
      subresource: subresource
      linkIndex: linkIndex
      subIndex: subIndex
    })
  ))
))

var endpointDetails = flatten(map(PrivateEndpointConfigs, (config, configIndex) => 
  map(filter(flattenedConfigs, item => item.config == config), (item, subIndex) => {
    linkType: item.linkType
    subresourceType: item.subresource.type
    endpointName: 'pep-${item.config.targetResource.name}-${toLower(replace(item.linkType, ' ', '-'))}-${item.subresource.type}'
    ipAddress: '${take(config.startingIpAddress, lastIndexOf(config.startingIpAddress, '.') + 1)}${int(split(config.startingIpAddress, '.')[3]) + subIndex}'
    dnsZone: item.subresource.dnsZones[0]
  })
))

var allEndpointDetails = map(PrivateEndpointConfigs, (config, i) => {
  resourceInfo: resourceInfos[i]
  subnetInfo: subnetInfos[i]
  endpointDetails: filter(endpointDetails, item => contains(config.privateLinkTypes, item.linkType) && startsWith(item.ipAddress, take(config.startingIpAddress, lastIndexOf(config.startingIpAddress, '.') + 1)))
})

var resourceInfoHtml = '''
<table style="width:100%; max-width:800px; border-collapse: collapse; margin-bottom: 10px; font-size: 11px;">
  <tr>
    <th style="width:30%; text-align: left; padding: 6px; background-color: #f2f2f2; border: 1px solid #ddd;">Resource Information</th>
    <th style="width:70%; text-align: left; padding: 6px; background-color: #f2f2f2; border: 1px solid #ddd;">Value</th>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Resource Name</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{0}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Resource Group</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{1}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Subscription ID</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{2}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Resource ID</td>
    <td style="padding: 6px; border: 1px solid #ddd; word-break: break-all;">{3}</td>
  </tr>
</table>
'''

var subnetInfoHtml = '''
<table style="width:100%; max-width:800px; border-collapse: collapse; margin-bottom: 10px; font-size: 11px;">
  <tr>
    <th style="width:30%; text-align: left; padding: 6px; background-color: #f2f2f2; border: 1px solid #ddd;">Subnet Information</th>
    <th style="width:70%; text-align: left; padding: 6px; background-color: #f2f2f2; border: 1px solid #ddd;">Value</th>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Subnet Name</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{0}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">VNet Name</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{1}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Resource Group</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{2}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Subscription ID</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{3}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Subnet ID</td>
    <td style="padding: 6px; border: 1px solid #ddd; word-break: break-all;">{4}</td>
  </tr>
</table>
'''
var privateEndpointHtml = '''
<h5 style="font-size: 11px; margin-top: 10px; margin-bottom: 5px;">Private Endpoint {0} of {1}: {2} - {3}</h5>
<table style="width:100%; max-width:780px; border-collapse: collapse; margin-bottom: 10px; font-size: 11px;">
  <tr>
    <th style="width:30%; text-align: left; padding: 6px; background-color: #e6e6e6; border: 1px solid #ddd;">Private Endpoint Information</th>
    <th style="width:70%; text-align: left; padding: 6px; background-color: #e6e6e6; border: 1px solid #ddd;">Value</th>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Subresource</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{3}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Private Endpoint Name</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{4}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Private Endpoint DNS Name</td>
    <td style="padding: 6px; border: 1px solid #ddd;">[To be filled]</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">IP Address</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{5}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Private DNS Zone</td>
    <td style="padding: 6px; border: 1px solid #ddd;">{6}</td>
  </tr>
  <tr>
    <td style="padding: 6px; border: 1px solid #ddd;">Documentation URL</td>
    <td style="padding: 6px; border: 1px solid #ddd;"><a href="{7}">{7}</a></td>
  </tr>
</table>
'''

var endpointDetailsHtml = map(allEndpointDetails, config => join(map(config.endpointDetails, (endpoint, endpointIndex) => format(privateEndpointHtml, 
  endpointIndex + 1, 
  length(config.endpointDetails), 
  endpoint.linkType, 
  endpoint.subresourceType, 
  endpoint.endpointName, 
  endpoint.ipAddress, 
  endpoint.dnsZone,
  resourceTypes[endpoint.linkType].url
)), ''))

var htmlOutput = join(map(range(0, length(allEndpointDetails)), i => format('''
<h3 style="font-size: 14px; margin-bottom: 10px;">Configuration {0} of {1} - {2}</h3>
{3}
{4}
<div style="border-left: 1px solid #ddd; padding-left: 20px;">
{5}
</div>
''',
  i + 1,
  totalConfigs,
  allEndpointDetails[i].resourceInfo.primaryLinkType,
  format(resourceInfoHtml, 
    allEndpointDetails[i].resourceInfo.name, 
    allEndpointDetails[i].resourceInfo.resourceGroup, 
    allEndpointDetails[i].resourceInfo.subscriptionId, 
    allEndpointDetails[i].resourceInfo.resourceId
  ),
  format(subnetInfoHtml, 
    allEndpointDetails[i].subnetInfo.name, 
    allEndpointDetails[i].subnetInfo.vnetName, 
    allEndpointDetails[i].subnetInfo.resourceGroup, 
    allEndpointDetails[i].subnetInfo.subscriptionId, 
    allEndpointDetails[i].subnetInfo.subnetId
  ),
  endpointDetailsHtml[i]
)), '<hr style="margin: 20px 0; border: none; border-top: 1px solid #ddd;">')

// ==================================================================================================

// Resource Section

// ==================================================================================================

// Output Section
output privateEndpointTicketDetails string = format('''
<div style="font-family: Arial, sans-serif; font-size: 12px; line-height: 1.6;">
<h2 style="font-size: 16px;">Private Endpoint Configuration Details</h2>

{0}

<p style="margin-top: 20px;">Please set up private endpoint(s) with the above configuration.</p>
</div>
''', htmlOutput)

// ==================================================================================================

// Type Section
@description('Private Endpoint Service Types')
type allowedPrivateLinkTypes = 'Azure AI services' | 'Azure Machine Learning' | 'Azure Event Hubs' | 'Azure Synapse Analytics' | 'Azure Synapse Studio' | 'Azure Data Factory' | 'Azure SQL Database' | 'Azure Cosmos DB' | 'Azure Service Bus' | 'Azure Automation' | 'Azure Monitor' | 'Microsoft Purview' | 'Azure Key Vault' | 'Azure App Configuration' | 'Storage account - Blob' | 'Storage account - Table' | 'Storage account - Queue' | 'Storage account - File' | 'Storage account - Web' | 'Azure Data Lake File System Gen2' | 'Azure Search' | 'Azure Web Apps'

@description('Private Endpoint Configuration Type')
type privateEndpointConfigType = {
  @description('Resource Configuration')
  targetResource: {

    @description('Resource Name')
    name: string

    @description('Resource Group Name')
    resourceGroupName: string?

    @description('Subscription ID')
    subscriptionId: string?
  }
  @description('Subnet Configuration')
  subnet: {
    @description('Subnet Name')
    name: string

    @description('VNet Name')
    vnetName: string

    @description('Resource Group Name')
    resourceGroupName: string

    @description('Subscription ID')
    subscriptionId: string?
  }
  @description('Starting IP Address')
  startingIpAddress: string

  @description('Private Endpoint Service Types')
  privateLinkTypes: allowedPrivateLinkTypes[]
}

// ==================================================================================================
