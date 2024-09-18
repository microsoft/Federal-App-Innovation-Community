
param apimInstance object
param apimEnv string

module javaApi 'javaAPI/javaApi.bicep' = {
  name: 'javaApi'
  params: {
    apimServiceName: apimInstance.name
    apimEnv: apimEnv
  }
}
