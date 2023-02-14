# Power Pages Secure Large Gigabyte File transer to Azure Datalake by External User Identies

## SUMMARY: The Solution provides a way for non AAD external user identies to securely upload large Gigabyte files to an Organizations AAD secured Azure Datalake

## WHAT PROBLEM DOES THE SOLUTION SOLVE?
* Organizations need to receive large files from external customers for Data AI workloads. But since the customers are external don’t have an organizational AAD Identity and thus dont have credentials. The Identity system built into Power Pages solves this problem.
* Where  are the files stored and how are they managed?  Azure Datalake solves this problem.

## SOLUTION: POWER PLATFORM + AZURE
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
  

## SOLUTION ARCHITECTURE
![Archiecture](Architecture.png)



## WORKFLOW 1 EXTERNAL USER REQUESTS PORTAL ACCESS. APPROVAL SENT TO INTERNAL TEAM/DEPT
A new user goes to the public portal site for the first time and has not been granted access and  yet given portal credentials. The user is seen as "Anonymous" and can thus only see a limited home page and a form to request access.  The new user submits the  Portal Access Form and an internal automated approval workflow is submitted for review by the internal managment team who receives an email. The approval is routed to a the correct team/department as configured by the combination of M365 Groups + Dataverse Business Unit. The request goes to only the correct team members in the corresponding M365 group. The reviewers are members of the M365 Group. The first one to respond completes the portal acess request approval and then workflow automatically creates a private registration code and emails the new user.  Permissions, web roles,email validation, and multi-factor authentication is automatically configures for the user. The user is sent an email and is redirected to the registraion site to one time create their registration and complete the credential grant process. The external user is now able to login to the portal.


![Request Portal Access Workflow](requestportalaccessworkflow.png)
## WORKFLOW 2 EXTERNAL USER REQUESTS FILE UPLOAD APPROVAL. SASTOKEN/SFTP CREDENTIALS CREATED
The external user is logged on to the portal with the previoulsy granted login credentials. They now request permission to upload a file.  The user submits a file upload request form which starts a similar approval process where by the approval request is sent to the corresponding internal department as configured by M365 Groups + Dataverse Business Units.  The first M365 Groups membrer to repond approves the request and then the Power Automate workflow calls a backend Azure Powershell Function that automaticall creates the corresponding Datalake file hierarchy and either a  SAS Token or SFTP credentials based on the user seleced option.  The credentials are emailed to the external user who procedes to upload the file(s).

![Request File Upload Workflow](requestfileuploadworkflow.png)

## WORKFLOW 3 NEW FILE UPLOADED USER NOTIFICATION AND RECORD FILE METADATA IN DATAVERSE FILES TABLE


![New File Upload Notification Workflow](newfileuploadednotificationworkflow.png)


## PRE-REQUISITES
* Power Apps Enviornment with Dataverse. Power Apps System
* Azure Subscription
## QUICKSTART
