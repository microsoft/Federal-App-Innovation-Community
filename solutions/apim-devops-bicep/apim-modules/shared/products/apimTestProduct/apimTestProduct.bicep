param apimInstanceName string

resource apimTestProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: '${apimInstanceName}/apimTestProduct'
  properties: {
    displayName: 'apim test product'
    subscriptionRequired: false
    state: 'published'
  }
   resource devGroup 'groups' = {
     name: 'developers'
   }

   resource guestGroup 'groups' = {
     name: 'guests'
   }
}
