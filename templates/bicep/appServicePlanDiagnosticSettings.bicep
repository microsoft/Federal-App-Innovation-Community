metadata description = 'This is a module and is not meant to be consumed as a primary template'

param ResourceName string

@description('The diagnostic settings of the service. See the type for object construction')
param DiagnosticSettings diagnosticSettingType[]?

resource _appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: ResourceName
}

resource _appServicePlanDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (DiagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${ResourceName}-diagnosticSettings'
    properties: {
      #disable-next-line use-resource-id-functions //The string resource Id of the storage account
      storageAccountId: diagnosticSetting.?storageAccountResourceId ?? null
      #disable-next-line use-resource-id-functions //The string resource Id of the log analytics workspace
      workspaceId: diagnosticSetting.?workspaceResourceId ?? null
      #disable-next-line use-resource-id-functions //The string resource Id of the event hub namespace
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId ?? null
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: group.?timeGrain ?? null
        }
      ]
      #disable-next-line use-resource-id-functions //This is not a resource Id, but a string property
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: _appServicePlan
  }
]


type diagnosticSettingType = {
  @description('The name of diagnostic setting.')
  name: string?

  @description('The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.')
  metricCategories: metricCategoryType[]?

  @description('A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}

type metricCategoryType = {
  @description('Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
  category: string

  @description('Enable or disable the category explicitly. Default is `true`.')
  enabled: bool

  @description('The time grain of the metric in ISO8601 format. If not specified, the default value is used by passing null.')
  timeGrain: string?
}
