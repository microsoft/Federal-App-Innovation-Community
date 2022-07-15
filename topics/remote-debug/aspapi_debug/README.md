# App Service Debugging with an ASP.NET Core API
This example demonstrates how to debug a ASP.NET Core API deployed to an App Service. This tutorial is intended to demonstrate a useful developer tool utilizing Azure App Services and enable developers to do more and remove roadblocks with existing tools. 

## Prerequisites  

* Powershell
* Azure Command Line (az)
* Bicep Command Line (bicep)
* An Azure subscription with contributor rights for a resource group
* Visual Studio 2017 or later with the "ASP.NET and web development" and "Azure Development" Extensions installed. 

> <b><i>Tested with Visual Studio 2022</i></b>
>  
> <b>Note</b>: When using earlier version use the cloud explorer to connect to the remote debugging. The cloud explorer was retired for Visual Studio 2022. 

### Upgrade all local tools
* Upgrade the bicep version
    `az bicep upgrade`
* Upgrade Azure CLI
    `az upgrade`
* Upgrade Visual Studio
    1. Go to the "Help" menu
    1. Select "Check for Updates".

### Components
* ./infrastructure/ - The bicep code for the App Service
* ./Source/DebugAPI/ - The Visual Studio Project
* ./Source/DeployFolder/ - The target folder for deployment
* ./Source/DeployThis.zip - Default deployment build for debugging

## Setup 
1. Create a resource group for deployment. This name will be reused in the next several steps.
1. Download this repository.
1. Open a Powershell command line to this repo folder.
1. On the command line login to Azure
        `az login`
1. Set the subscription, this step is needed if you have multiple subscriptions associated with your account
        `az account set --subscription [Subscription ID]`
1. Run the bicep command to create the necessary resources. Note the default D1 App Service plan will incur some cost. 
    `az deployment group create -g [ResourceGroup] --template-file '.\infrastructure\template.bicep' --parameters '.\infrastructure\parameters.json'`
1. Deploy the ASP.NET CORE API app. 
    `az webapp deploy --resource-group [ResourceGroup] --name aspdebug-[uniquename] --src-path '.\Source\DeployThis.zip'`
1. Confirm that the app service and swagger page is running and ensure that the default method returns results
    https://aspdebug-[uniquename].azurewebsites.net/swagger

## Connectivity
Remote Debugging requires connectivity over ports <b>4026, 4024, and 4022</b> to the App Service from the instance of Visual Studio connecting to it. Visual Studio web publishing requires port <b>8172</b>. This is in addition to the standard ports for App Services (<b>80 and 443</b>). Building the apps service on a private network could prevent communication over these ports. If necessary Azure has pre-configured VM images with Visual Studio installed and can be used from within the network to remote debug your application. 

This example uses an open ASP.NET Core API App Service. There are no network protections in this example. 

## Remote Debugging
Remote debugging requires the debugging symbols to be deployed to the remote target. This is done by building and deploying the project in the "Debug" configuration. The instructions below publish and deploy from Visual Studio.

> <b>Notes:</b> 
> 
> * Configuration for CI/CD will need to be changed in the build pipeline of your chosen CI/CD tool (Azure DevOps, GitHub, etc.).
>
> * The deployment and publishing settings are not included with this project. You will need to create a new deployment if you wish to make code changes for your own experimentation. 

1. Enable Remote Debugging. <i>Note: the application will restart at the end of this process.</i>
    In the Azure Portal:
    1. Go to the App Service resource
    1. Click on Configuration in the left hand menu
    1. Select "General Settings"
    1. Select "On" Under "Remote Debugging"
    1. Select your version of Visual Studio
    1. Click "Save" and "Continue" to save the settings and restart the App Service
1. Debugging remotely requires the solution be deployed from a "<i>Debug</i>" configuration. This was done earlier however may require a redeployment for remote debugging in your own App Service. To configure this setting on your own project...
    1. Right Click on the Project
    1. Select "Publish"
    1. If you have a publish configuration select look for configuration and click the edit button. 
    1. On the configuration screen select "Debug". The default is normally "Release" however this will strip all Debugging symbols and prevent the debugger from attaching. 
    1. Publish the App through the common means.
1. Attach the Visual Studio Debugger in 2022. 
    For earlier versions of Visual Studio use the Cloud Explorer (under the view menu) instead of the Connected Services
    In Visual Studio 2022
    1. Go to Connected Services in the Solution Explorer.
    1. Right Click and select "Managed Service Connections".
    1. Click "Add a Service Dependency".
    1. Login if necessary.
    1. Select the appropriate App Service and Click Select then Close.
    1. On the menu (three dots) to the right of the service open the menu. 
    1. Select Attach Debugger. This operation could take a while.
    1. Place a breakpoint in the WeatherForecastController.cs to view the code during execution. 

1. Once complete with the debugging disable the remote debugging on the app service. <i>Note: the application will restart at the end of this process.</i>
    In the Azure Portal:
    1. Go to the App Service resource
    1. Click on Configuration in the left hand menu
    1. Select "General Settings"
    1. Select "Off" Under "Remote Debugging"
    1. Click "Save" and "Continue" to save the settings and restart the App Service

## Clean Up

Delete the resource group and all contained components
