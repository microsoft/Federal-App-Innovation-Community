param apimInstance object

param apimEnv string

module products 'products/products.bicep' = {
  name: 'groupDeployment'
  params: {
    apimInstanceName: apimInstance.name
  }
}

module globalPolicies 'policies/policies.bicep' = {
  name: 'globalPolicies'
  params: {
    apimInstanceName: apimInstance.name
    apimEnv: apimEnv
  }
}
