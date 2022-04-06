
1. Specify the Cloud Environment:

```bash
#Azure Commercial Cloud
az cloud set --name AzureCloud

#Azure Government Cloud
az cloud set --name AzureUSGovernment
```

2. Login to your azure account from the CLI (you can either run `az login` or `az login --use-device-code` and apply the code from your terminal to the link that is output).

3. Create a `.env` file within your `hub-spoke-deployment` directory and provide the following values:

```bash
#Basic ARO Parameters
export ARO_RG=landing-zone
export ARO_LOCATION=eastus
export ARO_NAME=aro-cluster

#Network ARO Parameters
#Note that if you chance the values below they will need to align with what will be provided in the Bicep deployment for the VNETs / Subnets
export VNET_RG=landing-zone
export VNET=vnet-spoke-one
export VNET_ADDRESS="10.100.0.0/16"
export CONTROL_PLANE_SUBNET="snet-spoke-control-plane"
export CONTROL_PLANE_SUBNET_ADDRESS="10.100.1.0/24"
export WORKER_SUBNET="snet-spoke-worker-plane"
export WORKER_SUBNET_ADDRESS="10.100.2.0/24"
export ARO_VISIBILITY=Private

#ARO Worker Node Specs
export ARO_WORKER_NODE_SIZE=Standard_D4s_v3
export ARO_WORKER_NODE_COUNT=3
```

4. Set your shell with the values from your `.env` file:

```bash
set -a
source .env
set +a
```

5. Generate a Red Hat pull secret to obtain sample images and templates that can help you get started with OpenShift. Follow [these instructions](https://docs.microsoft.com/en-us/azure/openshift/tutorial-create-cluster#get-a-red-hat-pull-secret-optional) from the docs to obtain the pull secret. Once you have the secret, create a `pull-secret.txt` file in the `hub-spoke-deployment` directory so the script can use it later on when deploying ARO.

6. Deploy the environment, consisting of the resource group, the Bicep template, and the ARO Cluster:

> Note: When you run the Bicep Template, you will be prompted to provide a username / password for the VMs that your Bastion host will connect to so you can access the private cluster

> Info: When you run a Bicep / ARM Template, the resource providers referenced

```bash
#Create the resource group
az group create --name $ARO_RG --location $ARO_LOCATION

#Deploy Hub and Spoke Environment
az deployment group create --resource-group $ARO_RG --template-file landing-zone.bicep

#Deploy ARO within Spoke VNET
./az-aro-create.sh
```

7. Once complete, you can then select one of the VMs that were deployed (Ubuntu / Windows Server) and leverage the Bastion resource to securely connect to those VMs and interact with the private cluster.