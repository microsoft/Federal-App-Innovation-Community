# Deploy Simple AKS + ACR with Bicep

You can modify the RG Name, Deployment Location, and AKS Name in the params file

> Take note that the location option below is not to configure the location of your deployed resources, it is for the storage of the deployment resource associated with the subscription

```bash
az deployment sub create \
    --location <ENTER-LOCATION> \
    --template-file main.bicep \
    --parameters main.parameters.json
```
