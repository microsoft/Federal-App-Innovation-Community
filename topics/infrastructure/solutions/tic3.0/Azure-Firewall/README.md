# TIC 3.0 Compliant Demo using Azure Firewall

This repo supports an article on the Azure Architecture Center (AAC) - [Trusted Internet Connection (TIC) 3.0 compliance - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/security/trusted-internet-connections), it contains lots of great information on using the content of this repo. Please visit the article in the AAC before proceeding.

The following solution integrates Azure Firewall to manage the traffic into your Azure application environment. The solution includes all resources to generate, collect, and deliver logs to the CLAW. It also includes an app service to highlight the types of telemetry collected by the firewall.

![TIC 3.0 compliance using Azure Firewall and Application Service](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/trusted-internet-connections-architecture-AzFw.png)

### Requirements

The following must be performed before using this deployment scenario:

- None, solution will deploy as an isolated resource from existing Azure resources.

### Deploys and Updates

-  The solution includes:

  - A virtual network with a subnet for the firewall and servers.
  - A Log Analytics workspace.
  - Azure Firewall with a network policy for internet access.
  - Azure Firewall diagnostic settings that send logs to the Log Analytics workspace.
  - A route table associated with AppSubnet to route the app service to the firewall for the logs it generates.
  - A registered application
  - An Event Hub
  - An alert rule that sends an email if a job fails.

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/trusted-internet-connection-deploy-to-azure.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure-Firewall%2FComplete%2Fazuredeploy.json)

[![Deploy to Azure Gov](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/trusted-internet-connection-deploy-to-azure-gov.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure-Firewall%2FComplete%2Fazuredeploy.json)

### Post-deployment tasks for all solutions

Up to now your environment is performing the firewall capabilities and logging connections. To be TIC 3.0 compliant for Network Telemetry collection, those logs must make it to CISA CLAW. The post-deployment steps finish the tasks towards compliance. These steps require coordination with CISA because you will need a certificate from CISA to associate with your Service Principle. For step-by-step details see [Post Deployment Tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post-Deployment-Tasks).

The following tasks must be performed after deployment is complete. They are manual tasks—an ARM template can't do them.

- Obtain a public key certificate from CISA. 
- Create a Service Principle (App Registration).
- Add the CISA-provided certificate to the App Registration.
- Assign the application with the Azure Event Hubs Data Receiver role to the Event Hub Namespace.
- Activate Feed by sharing Azure Tenant ID, Application (client) ID, Event Hub Namespace name, Event Hub name, and Consumer group name with your CISA POC
