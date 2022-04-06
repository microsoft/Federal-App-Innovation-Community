param apimInstanceName string

param apimEnv string

var envConfigMap = {
  dev: {
    policyFile: loadTextContent('./dev-globalServicePolicy.xml')
  }
  staging: {
    policyFile: loadTextContent('./staging-globalServicePolicy.xml')
  }
  prod: {
    policyFile: loadTextContent('./prod-globalServicePolicy.xml')
  }
}

resource policy 'Microsoft.ApiManagement/service/policies@2021-08-01' = {
  name: '${apimInstanceName}/policy'
  properties: {
    format: 'rawxml'
    value: envConfigMap[apimEnv].policyFile
  }
}
