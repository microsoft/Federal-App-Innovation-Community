# Run Containerized Azure DevOps Agents that Dynamically Scale with AKS & KEDA

For those using Azure DevOps Server or Services (Cloud-Hosted), a great way to optimize resource utilization and make your agents dynamic/ephemeral is to [containerize your pipeline agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops) as opposed to running them as long-lived VMs. [VM Scale Set Agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops) also are not supported on Server, so we wanted to bring an approach that brings that scalability and dynamic scaling for parallel/queued jobs even to those running Azure DevOps Server.

This deployment assumes that a Virtual Network, Subnet, and Virtual NAT Gateway are created in Azure. If you do not have one, you can create one using the following command:

```bash
export RESOURCE_GROUP=<RESOURCE GROUP NAME>
export SUBNET=<SUBNET NAME>
export NAT_GATEWAY=<NAT GATEWAY NAME>
export PUBLIC_IP=<PUBLIC IP NAME>
export VNET=<VNET NAME>

az network public-ip create \
    --name $PUBLIC_IP \
    --resource-group $RESOURCE_GROUP \

az network nat gateway create \
    --name $NAT_GATEWAY \
    --resource-group $RESOURCE_GROUP \
    --public-ip-addresses $PUBLIC_IP

az network vnet create \
    --name $VNET \
    --resource-group $RESOURCE_GROUP \
    --address-prefix 10.0.0.0/16 \
    --subnet-name $SUBNET \
    --subnet-prefixes 10.0.0.0/24

az network vnet subnet update \
    --name $SUBNET \
    --vnet-name $VNET \
    --resource-group $RESOURCE_GROUP \
    --nat-gateway $NAT_GATEWAY

```

View the following video to see the demo live and to understand what this solution provides. The following instructions will allow you to deploy both Windows and Linux Agents on an AKS Cluster that has both Linux and Windows node pools.

> The video shows the concept for Linux Agents. This works the same way for Windows Agents and the following solution will deploy both. You can choose to deploy just one or the other if desired.

[![Scaling Containerized Azure DevOps Agents with AKS + KEDA](http://img.youtube.com/vi/06RF-I87jMs/0.jpg)](http://www.youtube.com/watch?v=06RF-I87jMs "Scaling Containerized Azure DevOps Agents with AKS + KEDA")

## 1. Run Bicep Deployment to Deploy AKS & ACR

Take note that the location option below is not to configure the location of your deployed resources, it is for the storage of the deployment resource associated with the subscription

```bash
export LOCATION=<LOCATION>

az deployment sub create \
    --location $LOCATION \
    --template-file bicep/main.bicep \
    --parameters bicep/main.parameters.json
```

### Additional Notes

This cluster is created with 3 node pools - a system node pool which will run system components (coredns, metric server, etc.), a linux node pool to be scheduled for linux agents, and a windows node pool for windows agents.

We want to be sure that we schedule linux agents only to the linux node pool and windows agents to the windows node pool. To do this, the Bicep deployment creates the two node pools with [node taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) so that a windows node can repel a set of pods not explicitly tolerating a windows node. Furthermore, to ensure that a pod itself is scheduled on the right node, the node label of `kubernetes.io/os` is used, which is automatically populated by the kubelet.

## 2. Build the Agent Images using ACR Tasks

Find the ACR Name by running `az acr list -g <RESOURCE-GROUP-NAME> -o table`

```bash
export RG_NAME=<RESOURCE-GROUP-NAME>
export ACR_NAME=<ACR-NAME>

az acr build \
    --registry $ACR_NAME \
    -g $RG_NAME \
    --image linux-agent:latest \
    dockeragent/linux/.

az acr build \
    --registry $ACR_NAME \
    -g $RG_NAME \
    --image windows-agent:latest \
    --platform windows \
    dockeragent/windows/.
```

## 3. Create Two Agent Pools in Azure DevOps with Placeholder Agents

First [create two new self-hosted agent pools](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&tabs=yaml%2Cbrowser#default-agent-pools). You will need one for the linux agents and another for the windows agents:

![agent pools](./images/agent-pools.png)

Next [create PAT tokens](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows) for agent authentication:

![linux agent pat](./images/linux-agent-pat.png)

![windows agent pat](./images/windows-agent-pat.png)

The PAT should have the following settings/permissions:

Organization: All accessible organizations (required to remove the agent from the pool)
Agent Pools: Read & manage

Finally, in order to enable KEDA to scale all the way down to zero for agents, it will be necessary to create a "placeholder" agent that is disabled/non-running.

Navigate to the linux agent pool and click New Agent. You can then download the agent tar file locally so that you can run the placeholder. Follow the steps to download the agent and only run the configure step, you will not actually run the agent itself:

```bash
# Copy download link on the agent page to get latest download version
mkdir agentdownload && cd agentdownload
wget https://vstsagentpackage.azureedge.net/agent/2.204.0/vsts-agent-linux-x64-2.204.0.tar.gz
tar zxvf vsts-agent-linux-x64-2.204.0.tar.gz

# Fill in the prompts accordingly for linux agent pool
# Example of config is shown below
./config.sh

# Remove the download after the config runs
cd ..
rm -rf ./agentdownload
```

![linux config](./images/linux-config.png)

![linux placeholder](./images/linux-agent-placeholder.png)

Navigate to the windows agent pool and go through the same steps. Technically the download is the same, but for a mental model and organization it helps to differentiate and see outputs accordingly:

```bash
# Copy download link on the agent page to get latest download version
mkdir agentdownload && cd agentdownload
wget https://vstsagentpackage.azureedge.net/agent/2.204.0/vsts-agent-linux-x64-2.204.0.tar.gz
tar zxvf vsts-agent-linux-x64-2.204.0.tar.gz

# Fill in the prompts accordingly for windows agent pool
./config.sh

# Remove the download after the config runs
cd ..
rm -rf ./agentdownload
```

![windows config](./images/windows-config.png)

![windows placeholder](./images/windows-agent-placeholder.png)

## 4. Deploy the Helm Chart to AKS to setup KEDA Scaling

First you should go to `helm/values.yaml` and make a copy of the file named `values-local.yaml`:

```bash
cp helm/values.yaml helm/values-local.yaml
```

See this [blog](https://medium.com/@shivam77kushwah/secure-secrets-using-azure-key-vault-with-helm-chart-a048525e4027) for how to pull directly from key vault for helm secrets. For this example, we will use a local values file.

From there, fill in the values per the comments in values-local.yaml. Here's an example of what a finished `values-local.yaml` should look like (the values provided here are representative of what might be your own once you customize):

Retrieve the pool id from the API similar to this where SIO-DEV is the collection where your pool exists:  
[https://devops.dosdev.us/SIO-DEV/_apis/distributedtask/pools?api-version=6.0](https://devops.dosdev.us/SIO-DEV/_apis/distributedtask/pools?api-version=6.0)

```yaml
# Default values for linuxAgentChart.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
namespace: devops

linux:

  image:
    acrLoginServer: acrwtytxpq2mm.azurecr.io
    name: linux-agent
    tag: latest

  secret:
    # THIS IS A CREDENTIAL - BE SURE NOT TO COMMIT TO REPO
    azpToken: 7zk11rjq2xkm6prhghaf6dpn2o44wn52yrjqxqt5q5lvfa2xc62a
    azpUrl: https://dev.azure.com/myorg

  job:
    poolName: linux-agent-pool
    runOnce: "True"

  trigger:
    poolId: 11
    targetPipelinesQueueLength: 1



windows:

  image:
    acrLoginServer: acrwtytxpq2mm.azurecr.io
    name: windows-agent
    tag: latest

  secret:
    # THIS IS A CREDENTIAL - BE SURE NOT TO COMMIT TO REPO
    azpToken: 8zk11rjq2xkm6prhghaf6dpn2o44wn52yrjqxqt5q5lvfa2xc62a
    azpUrl: https://dev.azure.com/myorg

  job:
    poolName: windows-agent-pool
    runOnce: "True"

  trigger:
    poolId: 12
    targetPipelinesQueueLength: 1
```

Once you have the `values-local.yaml` filled out, run the commands below to apply the template. You'll first need to connect to your AKS Cluster as shown below:

```bash
# Connect to AKS Cluster
export AKS_NAME=<AKS-CLUSTER-NAME>
az aks get-credentials -g $RG_NAME -n $AKS_NAME

# As a check, confirm you see the windows and linux nodes
# You should also see the system nodes
kubectl get nodes

# Apply templates
#lnx
helm template devops helm/. -f helm/values-local.yaml | kubectl apply -f -

#windows no path
<PATH_TO_HELM>\helm.exe template devops <PATH_TO_HELM_REPO_FOLDER>helm\. -f <PATH_TO_HELM_VALUES>\helm\values-local-dosdev.yaml | <PATH_TO_KUBECTL>\kubectl.exe apply -f -
```

## 5. Run Pipelines and See the Agents Scale

Now that you have the Scaled Jobs defined in your AKS Cluster, create Azure Pipelines that reference the self-hosted agent pools and you should now see the pods scale in and out as the queue add pipeline runs.

Here is an example starter pipeline that does a simple echo. Define two different pipelines and reference the different pools to have them scheduled either on the linux or windows agents:

```yaml
# Starter pipeline
# Start with a minimal pipeline that you can customize to build and deploy your code.
# Add steps that build, run tests, deploy, and more:
# https://aka.ms/yaml
trigger:
- main

pool: # linux-agent-pool | windows-agent-pool

steps:
- script: echo Hello, world!
  displayName: 'Run a one-line script'

- script: |
    echo Add other tasks to build, test, and deploy your project.
    echo See https://aka.ms/yaml
  displayName: 'Run a multi-line script'
```

See the agents scale with the following:

```bash
kubectl get jobs -n devops
kubectl get pods -n devops
```

Once you run the pipelines, you should see the jobs start as the queue builds. View the recording included to see how this works and how you can view that action taking place.

## Troubleshooting

### **Error**: The container operating system does not match the host operating system

Does the container OS match the node pools OS?

```dotnetcli
kubectl get nodes -o wide
```

This command is used to view information about your nodes, including the OS type and the taints applied to the nodes.


## References

- [Container Agent Repo by @georgdrobny](https://github.com/georgdrobny/ContainerAgent)

- [Windows Base Image](https://github.com/microsoft/dotnet-framework-docker/blob/a853e05e409b3009b059fa3945837765c9bc43b8/src/sdk/4.8/windowsservercore-ltsc2022/Dockerfile)