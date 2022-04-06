param apimInstanceName string

module apimTestProduct 'apimTestProduct/apimTestProduct.bicep' = {
  name: 'apimTestProduct'
  params: {
    apimInstanceName: apimInstanceName
  }
}
