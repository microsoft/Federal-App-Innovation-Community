param apimServiceName string
param apimEnv string

var envConfigMap = {
  dev: {
    url: 'https:DEV-URL'
  }
  staging: {
    url: 'https:STAGING-URL'
  }
  prod: {
    url: 'https:PROD-URL'
  }
}

//example openapi spec provided
resource javaApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${apimServiceName}/javaApi'
  properties: {
    path: 'javaApi'
    apiRevision: '1'
    apiRevisionDescription: 'initial api'
    displayName: 'java api'
    subscriptionRequired: false
    serviceUrl: envConfigMap[apimEnv].url
    protocols: [
      'https' 
    ]
    format: 'openapi+json'
    value: loadTextContent('openapi.json')
  }
}
