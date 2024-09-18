<!-- This module should be replaced by an APIOps Module -->

# APIM DevOps Workflow

## Deployment via CLI/Terminal

```bash
# COPY PARAMETERS TO LOCAL FILE
# FILL IN UNSPECIFIED PARAMS
cp main.parameters.json local.parameters.json

# SPECIFY LOCATION FOR DEPLOYMENT (USED FOR METADATA, NOT LOCATION FOR APIM DEPLOYMENT)
export LOCATION=eastus

# DEPLOY
az deployment sub create \
    --location $LOCATION \
    --name apim-deployment-`date +"%Y-%m-%d-%s"` \
    --template-file main.bicep \
    --parameters local.parameters.json \
    --confirm-with-what-if #if you want to see changes before confirming deployment
```
## Deployment via GitHub Actions

1. Setup your Environments
    
    * Create the Dev Environment
    * Create the Staging Environment
    * Create the Production Environment

1. Define the Service Principal

    ```bash
    # CREATE SERVICE PRINCIPAL FOR WORKFLOW
    # THIS WILL BE USED AS A GITHUB ACTIONS SECRET
    # BY DEFAULT WILL HAVE CONTRIBUTOR ON SUBSCRIPTION
    az ad sp create-for-rbac \
    --name BicepGitHubActionsSP \
    --role Contributor \
    --sdk-auth
    ```
2. Create a GitHub Secret named `AZURE_CREDENTIALS`

3. Run Workflow

## Initial Instantiation of APIM Instance

* [Service Configuration](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service?tabs=bicep)
    - SKU
    - [Capacity](https://docs.microsoft.com/en-us/azure/api-management/api-management-capacity)
    - Managed Identity
    - Certificates -> leverage Key Vault here
    - VNET Configuration

* [Shared Configuration](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products?tabs=bicep)
    - Products
    - Policies (Global/Product Level)
    - Loggers

## Portal Initialization

1. First you can seed your `portal-content` folder by capturing the content from an experimental APIM instance where you customized and updated the portal:

    ```bash
    cd api-management-developer-portal
    npm install

    cd scripts.v3
    node ./capture \
    --subscriptionId <SUB_ID_OF_DEV_APIM> \
    --resourceGroupName <RG_NAME> \
    --service-name <APIM_NAME> \
    --folder ../../portal-content
    ```

    > Moving forward you can now commit your portal content as an artifact you maintain like your other code and configuration for APIM

2. You can run manually the `generateAndPublish.js` script if you want to now publish this content to a specific APIM instance:

    ```bash
    cd api-management-developer-portal
    npm install

    cd scripts.v3
    node ./generateAndPublish.js \
    --subscriptionId <SUB_ID_OF_TARGET_APIM> \
    --resourceGroupName <RG_NAME> \
    --service-name <APIM_NAME> \
    --folder ../../portal-content
    ```

    > Note that the `portal-content` folder should have a `media` folder as well even if there are no contents in the `media` folder


## References

* [Bicep Linter](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/linter)