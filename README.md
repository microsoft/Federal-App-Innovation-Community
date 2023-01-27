# Federal Application Innovation Community Repository

This repository was created to demonstrate patterns, solutions, and demos for federal customers and partners. This guidance is built by an active open-source community with an authentic federal perspective. Teams can use this repository as a starting point to successfully implement cloud-native architectures and services in Azure Cloud & Azure Government Cloud.

The goal is to address high-value problems, unique scenarios, while providing actionable guidance and direction. You should refer to these solutions as a starting point to accelerate you cloud adoption journey. Feel free to fork a copy of this repository for your own use cases, requirements, experimentation, learning and cloud adoption journey.

## Solutions & Patterns

| Topic | Solution | Azure Global | Azure Government | Last Tested |
| :--------- | :--- | :----: | :----: | :---: |
| ***[Containers](./topics/containers)*** | ACR Tasks with Private Agents [▶️](./topics/containers/solutions/private-acr-tasks) | ✔️ | ✔️ | 03/31/2022 |
| ***[Kubernetes](./topics/kubernetes)*** | Deploy Azure RedHat OpenShfit [▶️](./topics/kubernetes/solutions/aro-kubernetes) | ✔️ | ✔️ | 03/31/2022 | 02/28/2022 |
| ***[DevSecOps](/topics/devsecops)*** | Deploy BigBang On Azure [▶️](./topics/devsecops/solutions/bigbang-on-azure/) | ✔️ | ✔️ | 06/08/2022 |
| ***[DevSecOps](/topics/devsecops)*** | Deploy BigBang On Azure Automated [▶️](./topics/devsecops/solutions/bigbang-on-azure-automated/) | ✔️ | ✔️ | 06/08/2022 |
| ***[Configure BigBang to use a Custom Registry](/topics/devsecops/)*** | Custom Registry on BB [▶️](//topics/kubernetes/solutions/bigbang-custom-registry) |  | ✔️ | 06/20/2022 |
| ***[CI/CD](./topics/ci-cd)*** | Manage APIM with Bicep + CI/CD [▶️](./topics/ci-cd/solutions/apim-bicep) | ✔️ | N/A | 02/28/2022 |
| ***[CI/CD](./topics/ci-cd)*** | Scaling Containerized Azure DevOps Agents with AKS + KEDA [▶️](./topics/ci-cd/solutions/containerized-agents-keda/) | ✔️ | N/A | 07/11/2022 |
| ***[Infrastructure](./topics/infrastructure)*** | TIC 3.0 Architectures [▶️](./topics/infrastructure/solutions/tic3.0) | ✔️ | ✔️ | 05/04/2022 |
| ***[Bot](./topics/bot)*** | Mobile Virtual Assistant [▶️](./topics/bot/solutions/mobile-virtual-assistant) | ✔️ | N/A | 05/20/2022 |
| ***[Cognitive Search](./topics/cognitive-search)*** | Document and Audio Parsing and Classification  [▶️](./topics/cognitive-search/solutions/document-parser) | ✔️ |  ✔️ | 06/08/2022 |
| ***[Modern Auth](./topics/modern-auth/React-MSAL-AAD)*** | React MSAL AAD Example  [▶️](./topics/modern-auth/React-MSAL-AAD) | ✔️ |  ✔️ | 01/24/2023 |
| ***[OpenAI](./topics/openai/README.md)*** | OpenAI ChatGPT text generation Example  [▶️](./topics/modern-auth/React-MSAL-AAD) | N/A |  N/A | 01/27/2023 |
## Training Resources

| Topic | Training | Azure Global | Azure Government |
| :---------: | :---: | :----: | :----: |
| ***[Serverless](./topics/serverless)*** | Cloud-Native Workshop with Functions + Cosmos [▶️](./topics/serverless/trainings/azure-functions-serverless-cloud-native-workshop) | N/A | N/A |
| ***[Remote Debugging](./topics/remote-debug/)*** | Remote Debugging on App Services | N/A | N/A |


## Whitepapers

| Topic | Whitepaper |
| :---------: | :---: |
| ***[Kubernetes](./topics/kubernetes)*** | Container Adoption Journey [▶️](./topics/kubernetes/whitepapers/container-adoption-journey) |

## Contributing




This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

### Guidelines

To contribute, you should fork this repository and then submit contributions as a Pull Request. Someone on the contributors team will review your pull request and we can work together to get it merged and address any updates that should occur.

[Creating a Pull Request from a Fork](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)

[![Fork and PR](https://img.youtube.com/vi/rrlXYiB1-Bc/sddefault.jpg)](https://youtu.be/rrlXYiB1-Bc)

### Automation & Testing

The contribution should have a clear approach for how to work through your solution & training resource. Ideally for solutions, we are looking for automated approaches using Infrastructure-as-Code (ideally Bicep or Terraform). However, we will welcome any form of automation including scripts since we want solutions to be added sooner rather than later and we can iterate from there.

Additionally, we have a focus on testing solutions both in [Azure Cloud and Azure Government](https://docs.microsoft.com/en-us/azure/azure-government/compare-azure-government-global-azure).

As part of the peer review process, we will attempt the test your solution so that we can validate the automation and also try to validate that the solution deploys across both clouds and addresses unique needs in either one (for example, [endpoints](https://docs.microsoft.com/en-us/azure/azure-government/compare-azure-government-global-azure#guidance-for-developers) may differ across the two clouds which should be addressed in your solution).

### Folder Naming Conventions

Follow the folder convention below to add your contribution. Generally we will look for automated solutions using Bicep, but within your particular solution feel free to leverage a different approach for automation like Terraform or even scripts with the `az cli`. We will be flexible with the folder structure within your solution as long as a `README.md` is provided for guidance on how it works.

Apply your opinion on what topic area your content should be included under (and if maybe a new topic is required, feel free to suggest that), we can then review on the PR should there be any other thoughts.

```
TOPIC AREA/
 ├─ sub-topic/
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
