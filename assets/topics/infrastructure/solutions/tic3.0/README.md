**Azure Front Door** vs **Azure Application Gateway** vs **Azure Firewall**

There are two types of firewalls in Azure; native Azure Firewall, layer 4, and Web Application Firewall, layer 7. 

*Azure Firewall* is a cloud-native and intelligent network firewall security service that provides the best of breed threat protection for your cloud workloads running in Azure. It's a fully stateful, firewall as a service with built-in high availability and unrestricted cloud scalability. It provides both east-west and north-south traffic inspection. Azure Firewall is a great solution for applications and services that require port translation, address translation, and/or direct egress to the internet. The Azure Firewall will secure the application with built-in rules, custom rules, and more. azure firewall.

*Azure Application Gateway* is a regional load balancer with support for a Web Application Firewall (WAF). Azure Application Gateway with WAF is a great solution for single-region applications and services. The Web Application Firewall will secure the application with built-in rules, custom rules, geo-filtering, and more. 

*Azure Front Door* is a global load balancer with support for a Web Application Firewall (WAF). Azure Front Door with WAF is a great solution for multi-region applications and services. The Web Application Firewall will secure the application with built-in rules, custom rules, geo-filtering, and more. 

**Azure Firewall**

- All services needed to deploy, secure, and monitor a TIC 3.0 application with an Azure Firewall are included. The deploy application service is running the default template to showcase its external accessibility and security. You can replace the default app service solution with your own custom application for a quick, TIC 3.0 compliance web application to your users and agency. 
- Deploy Virtual Network, App Service, AzureFirewall Subnet, Internal Subnet, Azure Firewall, Log Analytics workspace, Automation Account, Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace, and Alert. The deployed App Service will use private endpoint and Firewall DNAT rule on port 5443 for public access.
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 4 firewall logs to CISA CLAW.

**Azure Application Gateway**

- All services needed to deploy, secure, and monitor a TIC 3.0 application with an Azure Application Gateway are included. The deploy application service is running the default template to showcase its external accessibility and security. You can replace the default app service solution with your own custom application for a quick, TIC 3.0 compliance web application to your users and agency. 
- Deploy Virtual Network, App Service, AppGateway Subnet with Microsoft.Web service endpoint, App Gateway, Log Analytics workspace, Automation Account, Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace, and Alert. The deployed App Service will become the backend to the App Gateway and restricted to only accept request from the App Gateway IP. This configures the app so it is only accessible using App Gateway public IP.
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Azure Front Door**

-  All services needed to deploy, secure, and monitor a TIC 3.0 application with an Azure Front Door are included. The deploy application service is running the default template to showcase its external accessibility and security. You can replace the default app service solution with your own custom application for a quick, TIC 3.0 compliance web application to your users and agency.
- Deploy App Service, Front Door, Log Analytics workspace, Automation Account, Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace, and Alert. The deployed App Service will become the backend to the Front Door and restricted using service tag with ResourceID of the Front Door. This configures the app so it is only accessible using Front Door URL.
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 



**Additional Resources**

- [Firewall, App Gateway for virtual networks - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/gateway/firewall-application-gateway)