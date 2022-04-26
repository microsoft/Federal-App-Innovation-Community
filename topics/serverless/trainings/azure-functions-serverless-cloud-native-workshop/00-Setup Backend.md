# Serverless Cloud Native Workshop - Backend Setup
**Create the backend Api and setup Cosmos DB**
**Last Update**: 4/25/2022


# What we are building
We will be building a simple API that can support the bicycle shop SPA.

![Image](https://github.com/usri/ServerlessCloudNativeWorkshop/blob/master/Docs/arch.png?raw=true)

# Setup needed tooling

|  |  |
| ----------- | ----------- |
| Install NPM | https://nodejs.org/en/download/ |
| Install .net core | Windows: https://dotnet.microsoft.com/download/dotnet-core/thank-you/sdk-3.1.402-windows-x64-installer <br/> Mac: https://dotnet.microsoft.com/download/dotnet-core/thank-you/sdk-3.1.403-macos-x64-installer |
| Install Postman | https://www.postman.com/ |
| Install VS Code  | https://code.visualstudio.com/Download <br/> Default settings on OK. |
| Install Azure Funtions core tools | https://go.microsoft.com/fwlink/?linkid=2135274 <br> Mac: brew tap azure/functions <br> brew install azure-functions-core-tools@3|
| Install Azure Funtions Extension | ![Image](img/vscode-azfunc.jpg) |
| Install C# Extension | ![Image](img/vscode-csharp.jpg) |
| Close VS Code |  |
|  |  |
| Test Policy (optional) | https://www.postman.com/ |
| Test Policy from Powershell | Get-ExecutionPolicy -List |
| Set Poloicy from Powershell | Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force |

# Build Data Store
|  |  |
| ----------- | ----------- |
| Login to Azure Portal|  |
| Search for Cosmos|  ![Image](img/cosmos-create.jpg)  |
| Select Resource Group|  ![Image](img/cosmos-rg.jpg)  |
| Create Account Name|  ![Image](img/cosmos-accountname.jpg)  |
| Choose SQL Core|  ![Image](img/cosmos-sqlcore.jpg)  |
| Select Capacity Mode|  ![Image](img/cosmos-mode.jpg)  |
| Limit Throughput|  ![Image](img/cosmos-limit.jpg)  |
| Let it cook for 10 minutes |  |
| Get your connenction string | ![Image](img/cosmos-connectionstr.jpg) |

# Create Project in VS Code
|  |  |
| ----------- | ----------- |
| Open cmd prompt |   |
| Goto Root | cd \  |
| Make Folders | md Projects <br/> cd Projects <br/> md Backedn <br/> cd backend |
| Open VS Code | code.  |
| Open command pallet |  ![Image](img/vscode-cmdpallet.jpg)   |
| From commaned pallet create new project |  ![Image](img/vscode-cmdpallet.jpg)   |
| Select your folder |  ![Image](img/vscode-newproj.jpg)   |
| Select language (C#)  |  ![Image](img/vscode-language.jpg)   |
| Select .net version (.Net Core 3)  |  ![Image](img/vscode-dotnetver.jpg)   |
| Select 'HttpTrigger' as template |  ![Image](img/vscode-trigger.jpg)   |
| Enter 'Bike' as function name |  ![Image](img/vscode-funcname.jpg)   |
| Leave namesapce as it |  ![Image](img/vscode-namespace.jpg)   |
| Leave Access rights as 'Function' | ![Image](img/vscode-accessrights.jpg)  |
| Update CQRS settings |  |
| Add this to local.settings.json | , <br> "Host": { "CORS": "*"}  |
|  |   |
| Run the program |  F5  |
| Get URL to Bike API | ![Image](img/bike-api-url.jpg)   |
| Open Postman |   |
| Open cmd prompt | ![Image](img/postman.jpg)   |
| Open cmd prompt | ![Image](img/vscode-accessrights.jpg)   |


# Create your container
|  |  |
| ----------- | ----------- |
| In the Azure portal to go your cosmos instance |   |
| Navigate to Data Exploer | ![Image](img/cosmos-explorer.jpg)  |
| Make Folders | md Projects <br/> cd Projects <br/> md Backedn <br/> cd backend |
| Open VS Code | code.  |
| Open command pallet |  ![Image](img/vscode-cmdpallet.jpg)   |

# Other Resources
[What-the-hack](https://docs.microsoft.com/en-us/) is am opprutunity to build this as a hackathon!

# Other Resources
[What-the-hack](https://docs.microsoft.com/en-us/) is am opprutunity to build this as a hackathon!

# Other Resources
[What-the-hack](https://docs.microsoft.com/en-us/) is am opprutunity to build this as a hackathon!




