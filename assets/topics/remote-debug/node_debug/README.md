# NODE REMOTE DEBUGGING on an Azure App Service
This example demonstrates how to debug a node app deployed to an app service. This tutorial is intended to demonstrate a useful developer tool utilizing Azure App Services and enable developers to do more and remove roadblocks with existing tools. 

There is 1 folder in this example

1) infrastructure - Containing the Bicep scripts to setup the example as needed

> Note: This procedure will restart the webapp several times

## Prerequisites

1) Visual Studio Code locally installed with the Azure App Service Extension
1) Azure Resource Group with Contributor Rights
1) Azure CLI
1) Bicep 

### Upgrade all local tools
* Upgrade the bicep version
    `az bicep upgrade`
* Upgrade Azure CLI
    `az upgrade`

## Setup

1. Create a resource group name. This name will be reused in the next several steps.
1. Download this repository.
1. Open a Powershell command line to this repo folder.
1. On the command line login to Azure
        `az login`
1. Set the subscription, this step is needed if you have multiple subscriptions associated with your account
        `az account set --subscription [Subscription ID]`
1. Create a resource group if needed 
        `az group create --location centralus --name [Resource Group Name]`
1. Deploy the bicep Infrastructure 
        `az deployment group create --resource-group [Resource Group Name] --template-file .\infrastructure\webapp.bicep`


 At the end of this deployment a webapp and a B1 plan will be created in the Central US region. When browsing to the URL for the webapp you will get a default page showing the text "Hello World". 

## Debug the app
> <i><b>Wait, where is the code?</b></i>
> 
> The code will be downloaded to Visual Studio Code from the WebApp. No need to host the code locally.

### Instructions to Debug.
1) Open the Azure Tool and Login if needed
1) Browse the the webapp
1) Right click on the webapp and select start remote debugging
1) When Prompted select enable debugging
    This will restart the webapp
1) On the debug screen you can choose which files to select under the scripts folder
1) Set the breakpoint as necessary
1) Browse to the URL and hit the breakpoint
1) Disconnect from the Debugging session and select to disable debugging. 
    This will restart the webapp

## Clean Up

Delete the resource and all contained components


## References
* [Visual Studio Code App Service Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureappservice) 
* [Visual Studio Code Download](https://code.visualstudio.com/Download)
* [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Install Bicep](https://docs.microsoft.com/en-us/cli/azure/bicep?view=azure-cli-latest#az-bicep-install)
* [Debugging Node in Visual Studio Code](https://code.visualstudio.com/docs/azure/remote-debugging#:~:text=%20Azure%20Remote%20Debugging%20for%20Node.js%20%201,the%20App%20Service%20explorer%20and%20select...%20More%20)
