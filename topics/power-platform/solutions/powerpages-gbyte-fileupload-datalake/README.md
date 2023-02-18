# Power Pages Secure Large Gigabyte File transer to Azure Datalake by External User Identies

## SUMMARY: The Solution provides a way for users external to an organizational AAD tenant boundry to securely upload large Gigabyte files to that Organizations AAD secured Azure Datalake

## What Problem does the solution solve?
* Helps Organizations that maintain an AAD secured Azure infrastrue to receive large files from external customers that dont have an identity in the AAD tenant. For example for Data AI workloads.
* Provides a secure and managed Azure Datalake hierarchicial file system for extremely large scale and file sizes 300Gbytes or more
* Provides an automate the process of creating,managing, and securing external customer identties providing said external customer a mechanism to security upload large files to the organizational datalake. Power Pages provides an Identity managment system that can be federated with external identity providers such as AAD, B2C, and Login.gov
* Provides a Dataverse based records and audit system, logging every portal access request, every file upload, and every approval.

## Solution: Power Platform + Azure 
* **Power Pages** provide a portal for external users to register, login, and submit upload request forms. A
* **Dataverse** provides a relational database to store and audit Datalake uploads and other metadata about users, approvals, upload requests, and file location
* **Power Automate** provide automated workflow and backend services
* **Azure Powershell Functions** provide an automated way to create SAS Tokens and SFTP credentials Azure Blob Storage
* **Azure Datalake** provides  a hierarchical file system and secure petabyte storage at low cost
* **Azure Event Grid** monitors new file upload events and triggers Power Automate file management workflows.

## What the Solution Provides:
* A portal for external users to log on and fill out a form to request permissions to upload a file(s). The system handles up to 300Gbyte files.
* An approval workflow so that new users logins and file upload requests are approved by internal organizational employees
* An option for users to upload files via Java Script web app (hosted in Power Pages),SFTP (hosted in Azure Storage Account SFPT Service), or Azure Storeage Explorer (free and robust large file upload tool by Microsoft)
* A new file notification system that notifies the correct internal employee that a new file has been uploaded
* An audit and reporting system the records in Dataverse every portal access request, user login,file upload request, every file upload and every approval. The Files Table stores the metadata of every file uploaded and its properties, such as location, size, date uploaded, who uploaded, and who approved.
* The ability to federal external user identities with Power Pages Portal.  Such as the external user organizational AAD , Azure AAD B2C, Social Identities, etc.
  

## Solution Architecture
![Archiecture](Architecture.png)

## Solution Components:
1. Datverse Tables:
* **Portal Access Request**  custom  table that stores the portal acess requests. a new row triggers the Portal Access Request Power Automate Workflow
* **File Upload Requests**   custom table that stores the file upload requests. A new row triggers the File Access Request Power Automate workflow
* **Files**  custom table that stores metadata such as file name, size, upload date of blobs in the Data Lake
* **Account** Out-of-the-box standard table storing the Company Name.  
* **Contact** Out-of-the-box standard table storing the Contact Name (Portal User)
* **Business Unit** Out-of-the-box standard table storing the name of the Organizational Departments.  The email is mapped to the M365 Group email of the department.
* **Invitation** Out-of-the-box table storing the portal invitations
* **Web Role** Out-of-the-box table storing the Portal Web Roles.
2. Power Automate Flows:
* **Portal Access Request** is triggered on new row in the Portal Access Request Table.  Takes the external user submitted form data and sends an Approval to the corresponding Dept that the user selected
* **File Upload Request** is triggered on a new row in the File Upload Request Tables. Takes the form subitted and sends an Approval to the corresponding department. If approved, the flow calls the Azure Powershell function which creates the datalake file hierarchy and either SAS Token or SFTP credentials, based on user selection
* **Datalake Blob Events** is trigger on any new blob/file uploaded by way of the previously mentioned credentials. The flow reads the blob metadata , stores in the Files Table, and sends a notification to the corresponding Department.
3. Dataverse Environment
* **Provisioned with Dataverse** standard install
* **Business Units** configured to map to M365 Groups and email.  Power Platform Admin settings
* **Search** Power Platform Admin Settings
* **Email**  Power Platform Admin settings
4. Power Pages Portal
5. M365 Email enabled Security Groups
* one M365 groups for each Department.  Add/remove members to this group
6. Power Apps Solution.  
Solution will be imported into the provisioned environment
1. Azure Datalake
2. Azure Powershell Function
3. SPA  Single Page Application 
* used for smaller file uploads up to 5 Gbyte.  hosted in Power Pages portal
* 
   
   


## Workflow 1:   External User Requests Portal Access. Approval Workflow Triggered 
A new user goes to the public portal site for the first time and has not been granted access and  yet given portal credentials. The user is seen as "Anonymous" and can thus only see a limited home page and a form to request access.  The new user submits the  Portal Access Form and an internal automated approval workflow is submitted for review by the internal managment team who receives an email. The approval is routed to a the correct team/department as configured by the combination of M365 Groups + Dataverse Business Unit. The request goes to only the correct team members in the corresponding M365 group. The reviewers are members of the M365 Group. The first one to respond completes the portal acess request approval and then workflow automatically creates a private registration code and emails the new user.  Permissions, web roles,email validation, and multi-factor authentication is automatically configures for the user. The user is sent an email and is redirected to the registraion site to one time create their registration and complete the credential grant process. The external user is now able to login to the portal.


![Request Portal Access Workflow](requestportalaccessworkflow.png)
## Workflow 2: External User Requests permission and credentials to upload a file.  Triggers Approval worflow and automatic datalake credential creation
The external user is logged on to the portal with the previoulsy granted login credentials. They now request permission to upload a file.  The user submits a file upload request form which starts a similar approval process where by the approval request is sent to the corresponding internal department as configured by M365 Groups + Dataverse Business Units.  The first M365 Groups membrer to repond approves the request and then the Power Automate workflow calls a backend Azure Powershell Function that automaticall creates the corresponding Datalake file hierarchy and either a  SAS Token or SFTP credentials based on the user seleced option.  The credentials are emailed to the external user who procedes to upload the file(s).

![Request File Upload Workflow](requestfileuploadworkflow.png)

## Workflow 3:   New File Uploaded Notification to Department. New File metadata stored in the Files table

![New File Upload Notification Workflow](newfileuploadednotificationworkflow.png)

## Data Model

![Dataverse Datamodel](datamodel.png)



## Pre-Requisites
1. Power Apps Enviornment with Dataverse. 
   - Power Apps System Adamin role
    
2. Azure Subscription
   - permissions to create and configure azure datalake
   - permissions to create and deploy Azure Funtion App in App service
## Deployment
1. **Power Platform**
     1. **Create a New Dataverse Environment**
        1. Open Power Platform admin center with System Administrator role.Select Environments/ New to  Create Dataverse Environment with Dataverse. 
        2. Choose Sandbox. Select the Create a database for this environment switch. 
        3. No need to enable Dynamics 365 or sample apps. 
        4. Select Save to provision the new environment
     
     2.  **Configure Dataverse Environment**
         1.  Configure Business Units for Datavese in power platform admin settings
         2.  Configure email for Dataverse in power platform admin setting
         3.  Configure Search in power platform admin settings
           
     3.  **Create a Power Platform Admin Service Principal**
         1.  In the AAD Admin Council Create an AAD user  called for exmple Power Platform Admin . this will be used by the connections and flow email from the flow. Assign power platform and power automate licence.
         2.  Assign Power Platform Administer role in AAD and System Admin role in Dataverse
         3.  Disable MFA for this principal
       
    4. **Create M365 Groups emailed enabled security groups for Organication Departments**
       1. Go in AAD Admin.  Create an new M365 group. select and copy the email address of the group.  Add users to the respective group.
       2. Copy the M365 group email, it will be used later when you configure Dataverse Business Units
  
    5. **Create Connections in the new environment.** These will be used when the solution is imported.  Use the previouly created service principal
       1. Microsoft Teams
       2. Approvals
       3. Microsoft Dataverse
       4. Office 365 OUtlook
       5. Office 365 Groups
       6. Azure Event Grid
    6. Create Portal
       1. From Power Apps Studio Select New App/website
       2. Pick a name.  Do **not** chose the "Use data from existing website record".  
       3. Select Create The portal could take 30 or more minutes to provision.
        
    7. **Import Portal Config** 
     
    9. **Import Solution**
       1.  Download the solution.zip file to your local hard drive.
       2.  In the Power Apps Studio select your newly created environment
       3.  Select Soluions/Import Solution to import the downloaded solution    
      
1. **Azure**
   1. **Create a Resource Group**
   2. **Create a Azure Function App**
      1. Yype Powershell core. Give it a name such as PowerPortalFileManagement
      2. You can choose Consumption , Premium, or App Service Plan based on the use case
      3. Deploy the Function app in the solution  to the Function app you just created.
      4. Create system assigned managed identity and add role assignment  scope=storage resource= your storage account Role = contributer
      5. TODO: write powershell creation and deployment script to upload function and app settings
         1. first login in to the cloud from az command line
            1. az cloud set --name AzureUSGovernment
            2. az login
         2. Deploy Function App
            1. az functionapp deployment source config-zip -g greg-powerportal-largefile -n PowerPortalFileManagement --src  PowerPortalFileManagement2.zip
         3. Configure App Configureation Setting for your environment
            1. az functionapp config appsettings set --name MyFunctionApp --resource-group MyResourceGroup --settings "AzureWebJobsStorage=$storageConnectionString"
               1. ResourceGroup: xxresoursegroupname
               2. StorageAccountName: xxdatalake4powerpages
               3. Subscription: 0035cc8c-1269-4fb4-8f16-xxxxxxxxxxx
               4. Tenant: ba1e9f6b-2cec-4c10-8616-xxxxxxxxxxx
               5. Cloud: AzureUSGovernment
               6. connectionstring:  "xxxxxxxxget from storage account access keys"
               7. ftp_endpoint: "the base of the ftp endpoint e.g. datalake4powerpages.blob.core.usgovcloudapi.net  get from SFTP User setting"
                  1. see https://learn.microsoft.com/en-us/cli/azure/functionapp/config/appsettings?view=azure-cli-latest
                  2. see https://learn.microsoft.com/en-us/azure/azure-functions/deployment-zip-push#cli
               8. Copy the Funtion URL. This will be used on the Env Variable when you import the solution. you can find the URL in the azure portal Overview main page for the deployed function app.
                
   3.  **Create Datalake / Azure Storage Account**
       1.  TODO: Write a powershell script to create and deploy Azure Storeage Account
       2.  addition to the defaults, select the following options
           1.  Enaable hierarchical namespace
           2.  Enable SFTP
           3.  Configure CORS
       3.  keep the remaining defaults and select create
       4.  once the storage account is created enable static website.  use $index and $error for document paths.copy the primary endpoint for later use
       5.  
   4.  **Creat Event Grid and Subscription** for new blob events in the newly created Storage Account for Datalake
       1.  TODO: Create PowerShell Script to create and deploy Event Grid and Subscription
         
   5.  **Configure Static SPA**
     
   


