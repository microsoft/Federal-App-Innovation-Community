# Architecture Design 

Please follow the instructions provided below to deploy and configure resources in Azure for either apim_api or code_api.

**Important Security Notice**: To enhance security, the created Cosmos DB, MySQL Flexible Server, and App Service will all be restricted to access only from your specified IPv4 address.

## MySQL Setup
To create the architecture needed for this API, please follow the below steps:
1. [Download the MySQL Installer](https://dev.mysql.com/downloads/workbench/):
Use the MySQl Installer to download MySQL Workbench. MySQL Workbench is a unified visual tool that helps you manage and design MySQL databases efficiently. ***This is how you will view and edit all the sql schema captured from the MySQL API.***

2. [Execute the ARM Template](mysql/mysql_arm.json): To create all the Azure resources for this API, execute the following ARM template from Azure CLI `mysql_arm.json`. 
    - Modify the parameter names and values as applicable. 
    - If using APIM, you will need to allow the APIM resource public IP through firewall. 

        The created resources will include:

        - [Azure MySQL Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/overview)
        - [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
        - [App Service Plan](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
        - [Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/overview)

        To deploy the resources in azure run the `mysql_arm.json` ARM template file in PowerShell or Bash terminal:

        Navigate to `\mysql` directory:
        ```shell
        cd api\architecture_setup\mysql
        ```

        Execute the `az` command:
        ```shell
        az deployment group create --resource-group <insert your RG> --template-file mysql_arm.json
        ```
3. [Connect Flexible Server to MySQL Workbench](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/connect-workbench): Please click the URL to be directed to Microsoft Learn documentation on connecting the server to Workbench. 

4. [Create aoai_api Schema in MySQL Server](aoai_api_v2.sql) : To create the scehma for the aoai api database, please follow these steps:

    1. In the top left menu bar, select **File**. 
    2. From the dropdown menu, select **Open SQL Script**.
    3. Download the `aoai_api_v2.sql` MySQL schema script from [here](mysql/aoai_api_v2.sql).
    4. Click the lighting bolt icon, without cursor icon, to execute the script. 
    5. At this point, the schema `aoai_api` should be created in your server. 

5. [Push API Docker Image to the created ACR from step 2](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-powershell): DockerFile provided for all API's in their perspective directory. Click a link below to be navigated to each:
    - [apim_api](../api/apim_api/Dockerfile)
    - [code_api](../api/code_api/Dockerfile)
    
    **You can build and push the Docker image all in one command using**:
    ```shell
    az acr build --registry "$CONTAINER_REGISTRY_NAME" --image "$CONTAINER_IMAGE_NAME" --file "api/<choose api directory>/Dockerfile" .  
    ```
    ***Note: Execute the build and push command from the root directory for this repository.***

## CosmosDB Setup

1. [Execute the ARM Template](cosmos/cosmos_arm.json): To create all the Azure resources for this API, execute the following ARM template from Azure CLI `cosmos_arm.json`. 
    - Modify the parameter names and values as applicable. 
    - If using APIM, you will need to allow the APIM resource public IP through firewall. 

    The created resources will include:

    - [Azure CosmosDB](https://learn.microsoft.com/en-us/azure/cosmos-db/)
    - [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
    - [App Service Plan](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
    - [Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/overview)

    To deploy the resources in azure run the `cosmos_arm.json` ARM template file in PowerShell or Bash terminal:

    Navigate to `\mysql` directory:
    ```shell
    cd api\architecture_setup\mysql
    ```

    Execute the `az` command:
    ```shell
    az deployment group create --resource-group <insert your RG> --template-file cosmos_arm.json`
    ```

2. [Push API Docker Image to the created ACR from step 1](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-powershell): DockerFile provided for all API's in their perspective directory. Click a link below to be navigated to each:
    - [apim_api](../api/apim_api/Dockerfile)
    - [code_api](../api/code_api/Dockerfile)
    
    **You can build and push the Docker image all in one command using**:
    ```shell
    az acr build --registry "$CONTAINER_REGISTRY_NAME" --image "$CONTAINER_IMAGE_NAME" --file "api/<choose api directory>/Dockerfile" .  
    ```
    ***Note: Execute the build and push command from the root directory for this repository.*** 



