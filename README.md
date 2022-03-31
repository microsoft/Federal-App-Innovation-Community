# Federal Application Innovation Community Repository

This repository was created to demonstrate patterns, solutions, and demos that teams can use as starting points to successfully implement cloud-native architectures and services in Azure Cloud and Azure Government Cloud.

The goal is to address high-value problems, unique scenarios, and provide direction. You should refer to these solutions as starting points that you can then customize, fork, etc. for your own use cases and requirements.

## Solutions & Patterns

| Topic | Solution | Azure Global | Azure Government |
| :--------- | :--- | :----: | :----: |
| ***[Containers](solutions/containers/)*** | Build Containers on ACR and Resolve Private Dependencies [▶️](solutions/containers/private-acr-tasks/README.md) | ✔️ | ✔️ |
| ***[ARO-Kubernetes](solutions/aro-kubernetes/)*** | Deploy ARO in a Private Hub & Spoke Network [▶️](solutions/aro-kubernetes/hub-spoke-deployment/README.md) | ✔️ | ✔️ |
| ***Continuous Integration/Continuous Deployment*** | Deploy & Manage APIM with Bicep & GitHub Actions/Azure DevOps [▶️](solutions/ci-cd/apim-bicep/README.md) | ✔️ | 🧪(#10) |

## Whitepapers

| Topic | Whitepaper | Azure Global | Azure Government |
| :---------: | :---: | :----: | :----: |

## Training Resources

| Topic | Training | Azure Global | Azure Government |
| :---------: | :---: | :----: | :----: |
| ***Containers / K8s*** | Azure Red Hat OpenShift Concepts ▶️ | ✔️ | 🧪 (#11) |

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

### Guidelines

To contribute, you should fork this repository and then submit contributions as a Pull Request. Someone on the contributors team will review your pull request and we can work together to get it merged and address any updates that should occur.

[Creating a Pull Request from a Fork](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)

### Automation & Testing

The contribution should have a clear approach for how to work through your solution & training resource. Ideally for solutions, we are looking for automated approaches using Infrastructure-as-Code (ideally Bicep or Terraform). However, we will welcome any form of automation including scripts since we want solutions to be added sooner rather than later and we can iterate from there.

Additionally, we have a focus on testing solutions both in [Azure Cloud and Azure Government](https://docs.microsoft.com/en-us/azure/azure-government/compare-azure-government-global-azure).

As part of the peer review process, we will attempt the test your solution so that we can validate the automation and also try to validate that the solution deploys across both clouds and addresses unique needs in either one (for example, [endpoints](https://docs.microsoft.com/en-us/azure/azure-government/compare-azure-government-global-azure#guidance-for-developers) may differ across the two clouds which should be addressed in your solution).

### Folder Naming Conventions

Follow the folder convention below to add your contribution. Generally we will look for automated solutions using Bicep, but within your particular solution feel free to leverage a different approach for automation like Terraform or even scripts with the `az cli`. We will be flexible with the folder structure within your solution as long as a `README.md` is provided for guidance on how it works.

```
solutions/
├─ your-new-solution-folder/
│  ├─ bicep/
│  │  ├─ main.bicep
|  |  ├─ modules/
|  ├─ img/
|  |  ├─ architecture.png
│  ├─ README.md
whitepapers/
├─ your-new-whitepaper-folder/
│  ├─ files/
│  │  ├─ image1.PNG
│  ├─ README.md
trainings/
├─ your-new-training-folder/
│  ├─ files/
│  │  ├─ image1.PNG
│  ├─ README.md
README.md
```

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
