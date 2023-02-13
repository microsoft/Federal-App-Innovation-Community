# Power Pages Secure Large Gigabyte File transer to Azure Datalake by External User Identies

## The Solution provides a way for non AAD external user identies to securely upload large Gigabyte files to an Organizations AAD secured Azure Datalake

## What Problen does the Solution Solve?
* Organizations need to receive large files from external customers for Data AI workloads.
* But since the customers are external and don’t have an AAD Identity how do they get credentials to securely transfer files?
* Where  are the files stored and how are they managed?

## Solution: Power Platform + Azure
* Power Pages provide a portal for external users to register, login, and submit upload request forms
* Dataverse provides a relational database to store and audit Datalake uploads and other metadata about users, approvals, upload requests, and file location
* Power Automate provide automated workflow and backend services
* Azure Functions provide an automated way to create SAS Tokens and SFTP credentials Azure Blob Storage
* Azure Datalake provides  a hierarchical file system and secure petabyte storage at low cost
* Azure Event Grid monitors new file upload events and triggers Power Automate file management workflows.

## Reference Archiecture
![Archiecture](/docs/architecture.png)

## Workflows
![Request Portal Access Workflow](/docs/requestportalaccessworkflow.png)

![Request File Upload Workflow](/docs/requestfileuploadworkflow.png)

![New File Upload Notification Workflow](/docs/newfileuploadednotificationworkflow.png)


## Pre-Requisites

## Quickstart




