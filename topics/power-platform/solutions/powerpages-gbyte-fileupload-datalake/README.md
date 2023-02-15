# Power Pages Secure Large Gigabyte File transer to Azure Datalake by External User Identies

## SUMMARY: The Solution provides a way for users external to an organizational AAD tenant boundry to securely upload large Gigabyte files to that Organizations AAD secured Azure Datalake

## What Problem does the solution solve?
* Organizations need to receive large files from external customers for Data AI workloads. But since the customers are external don’t have an organizational AAD Identity and thus dont have credentials. The Identity system built into Power Pages solves this problem.
* Where  are the files stored and how are they managed?  Azure Datalake solves this problem.

## Solution: Power Platform + Azure 
* **Power Pages** provide a portal for external users to register, login, and submit upload request forms
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
* **Account** Built in standard table storing the Company Name.  
* **Contact** Built in standard table storing the Contact Name (Portal User)
* **Business Unit** Built in standard table storing the name of the Organizational Departments.  The email is mapped to the M365 Group email of the department.
* **Invitation** Built in table storing the portal invitations
* **Web Role** Built in table storing the Portal Web Roles.
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
1. Power Platform 
    - Create a New Dataverse Environment
      - Open Power Platform admin center with System Administrator role
      - Select Environments/ New to  Create Dataverse Environment with Dataverse. Choose Sandbox. 
      - Select the Create a database for this environment switch
      - no need to enable Dynamics 365 or sample apps
      - Select Save to provision the new environment
      - Configure email for Dataverse in power platform admin setting
      - Configure Business Units for Datavese in power platform admin settings
      - Configure Search in power platform admin settings
    - Power Platform Identity
      - create an AAD user Identity call Power Platform Admin . this will be used by the connections
      - assign power platform and power automate licence
      - assign Power Platform Administer role in AAD and System Admin role in Dataverse
    - M365 Groups
      - Create a email enables M365 group for each Organizational Department that will be receiving and managing their own portal access and file upload requests
      - go in AAD Admin.  Create an new M365 group. select and copy the email address of the group.  Add users to the respective group
      - the email will be used later when you configure Dataverse Business Units
    - Teams Groups
      - create a new Team for each for the M365 Groups previusly created
    - Create Connections in the new environment for the following. These will be used when the solution is imported
      - Microsoft Teams
      - Approvals
      - Microsoft Dataverse
      - MS Graph Groups and Users
      - Office 365 OUtlook
      - Office 365 Groups
      - Azure Event Grid
    - Create Portal
      - From Power Apps Studio Select New App/website
      - Pick a name.  Do **not** chose the "Use data from existing website record".  Select Create The portal could take 30 or more minutes to provision.
      - Import Portal Config 
    - Import Solution
      - download the solution.zip file to your local hard drive.
      - In the Power Apps Studio select your newly created environment
      - Select Soluions/Import Solution to import the downloaded solution
      - 
  

    
    

2. Azure 
    - Create a Resource Group
    - Create a Web App.
      -  Give it a name such as PowerPortalFileManagement
      -  
    - upload Function app to the Web App
    - Create a new storage account
      - in addition to the defaults, select the following options
        - Enaable hierarchical namespace
        - Enable SFTP
      - keep the remaining defaults and select create
      - once the storage account is created enable static website.  use $index and $error for document paths.copy the primary endpoint for later use
    - Event Grid and Subscription for new blob events in the newly created Storage Account for Datalake
    - Create M365 Groups that map to the Departments. Copy the email address
    - Create Static app
    - Enable SFTP


