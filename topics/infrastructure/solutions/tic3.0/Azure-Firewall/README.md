# TIC 3.0 Compliant App Service using Azure Firewall
## Problem Statement

Federal organizations and government agencies are the most likely implementers of TIC 3.0 compliance solutions for their Azure-based web applications and API services. Version 3.0 of the Trusted Internet Connection (TIC) migrates TIC from on-premises data collection to a cloud-based approach that better supports modern cloud-based applications and services. TIC 3.0 telemetry collection is driven by a firewall. 

There are two types of firewalls in Azure; native Azure Firewall, layer 4, and Web Application Firewall, layer 7. Azure Firewall is a cloud-native and intelligent network firewall security service that provides the best of breed threat protection for your cloud workloads running in Azure. It's a fully stateful, firewall as a service with built-in high availability and unrestricted cloud scalability. It provides both east-west and north-south traffic inspection. Azure Firewall is a great solution for applications and services that require port translation, address translation, and/or direct egress to the internet. The Azure Firewall will secure the application with built-in rules, custom rules, and more. azure firewall

## Demo Solution

The following solution is a one-click, out-of-the-box deployment. All services needed to deploy, secure, and monitor a TIC 3.0 application with an Azure Firewall are included. The deploy application service is running the default template to showcase its external accessibility and security. You can replace the default app service solution with your own custom application for a quick, TIC 3.0 compliance web application to your users and agency. 

###### TIC 3.0 Compliant App Service Architecture using Azure Firewall

![Architecture](https://raw.githubusercontent.com/microsoft/Federal-App-Innovation-Community/main/topics/infrastructure/solutions/tic3.0/images/Arch-AzureFirewall.png)

### Requirements
The following must be performed before using this deployment scenario:
- None, solution will deploy as an isolated resource from existing Azure resources.

### Deploys and Updates
Deploy Virtual Network, App Service, AzureFirewall Subnet, Internal Subnet, Azure Firewall, Log Analytics workspace, Automation Account, Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace, and Alert. The deployed App Service will use private endpoint and Firewall DNAT rule on port 5443 for public access.

This deployment scenario will deploy and update the following:

- Deploy Virtual Network with subnet for application and an Azure Firewall
- Deploy subnet for Azure Firewall
- Deploy Firewall policy
- Associate Firewall policy with Azure Firewall
- Associate WAF with Azure Firewall
- Deploy App service with default template
- Configure App service with restricted access for the Azure Firewall's subnet
- Configure Azure Firewall to route traffic to the application so that users must use a URL associated with the public IP of the Azure Firewall to connect to the application
- Deploy Log Analytics workspace
- Configure Azure Firewall Diagnostic Settings to send logs and metrics to Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

## Deployment Methods
### Azure Portal
Use the following button to deploy to Azure Commercial or Azure Government using the Azure Portal.

| [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmicrosoft%2FFederal-App-Innovation-Community%2Fmain%2Ftopics%2Finfrastructure%2Fsolutions%2Ftic3.0%2FAzure-Firewall%2Fazuredeploy.json) | [![Deploy to Azure Government](https://raw.githubusercontent.com/paullizer/Federal-App-Innovation-Community-1/main/topics/infrastructure/solutions/tic3.0/images/deploytoazuregov.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmicrosoft%2FFederal-App-Innovation-Community%2Fmain%2Ftopics%2Finfrastructure%2Fsolutions%2Ftic3.0%2FAzure-Firewall%2Fazuredeploy.json) |
| :----------------------------------------------------------: | :----------------------------------------------------------: |

### Azure PowerShell
The following PowerShell code can be executed from the Azure Cloud Shell or locally if you have [installed Az Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.3.2). 

You must update the **SubscriptionName** with your Azure Subscription that you want to deploy the solution

```powershell
$jsonUrl = "https://raw.githubusercontent.com/microsoft/Federal-App-Innovation-Community/main/solutions/infrastructure/tic3.0/Azure-Firewall/azuredeploy.json"
$location = "East US"
$resourceGroupName = "RG-Example-Tic3_0-AzureFirewall"
$suffix = Get-Random -Maximum 1000

Connect-AzAccount
Set-AzContext -SubscriptionName "SubscriptionName"
New-AzResourceGroup -Name ($resourceGroupName+"-"+$suffix) -Location $location 
New-AzResourceGroupDeployment -ResourceGroupName ($resourceGroupName+"-"+$suffix) -TemplateUri $jsonUrl`
```

## Post Deployment Tasks
To finalize TIC 3.0 compliance the following tasks must be completed to actually deliver your logs to the CISA CLAW.
- Coordinate with your CISA POC to receive your 
  - CLAW S3 Access Key (aka Id)
  - CLAW S3 Access Secret
  - CLAW S3 Bucket Name
  
### Update Automation account variables
The ARM template created variables that are used by the runbook to access the Log Analytics workspace using the application's service principle. Some variables will need to be updated over time. The CLAW secrets will expire. It is important to coordinate receipt of a new CLAW secret before it expires.

The variables are encrypted. This means that you or anyone cannot view them from portal or consoles. They can only be decrypted from within a runbook. When you update a variable because a secret is expiring or you want to use a different Log Analytics workspace, you just edit the value which overwrite the existing when you save it.

This example walks through updating the **AWSAccessKey**, repeat the steps for each Variable. 

![Edit Variable](https://raw.githubusercontent.com/microsoft/Federal-App-Innovation-Community/main/topics/infrastructure/solutions/tic3.0/images/UpdateAutoAcctVar-Edit.png)

![Save Variable](https://raw.githubusercontent.com/microsoft/Federal-App-Innovation-Community/main/topics/infrastructure/solutions/tic3.0/images/UpdateAutoAcctVar-Save.png)

1. Go to the Automation account created during deployment
2. Select **Variables** from the left hand menu, you will have to scroll down to view it
3. Select **AWSAccessKey**,
   1. You will start with this variable but you must update each variable
4. Select **Edit value**
5. Enter the AWS Access Key provided to you by CISA
6. Select **Save**

Repeat for **AWSSecretKey** and **S3BucketName**

## Ready for uploading logs to CLAW
Logs from your deployed scenario will be uploaded to the CLAW starting 1 hour after the deployed scenario and then every 15 minutes.

## References

[Trusted Internet Connection (TIC) 3.0 compliance - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/security/trusted-internet-connections)