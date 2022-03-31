#setup directory
mkdir deploy

#get cloud configuration provider secret which has service principal creds
oc get secrets -n kube-system
oc describe secret azure-cloud-provider -n kube-system
azure_cnf_secret=$(oc get secret azure-cloud-provider -n kube-system -o jsonpath="{.data.cloud-config}" | base64 --decode)
echo "Azure Cloud Provider config secret " $azure_cnf_secret
azure_cnf_secret_length=$(echo -n $azure_cnf_secret | wc -c)
aadClientId="${azure_cnf_secret:13:36}"
aadClientSecret="${azure_cnf_secret:67:$azure_cnf_secret_length}"

#additional account properties
#IMPORTANT : the managed rg name below is the managed/infra resource group name that ARO owns
subId=$(az account show --query id)
tenantId=$(az account show --query tenantId -o tsv)
managed_rg=$(az aro show -n <CLUSTER_NAME> -g <RESOURCEGROUP_NAME> --query 'clusterProfile.resourceGroupId' -o tsv)
managed_rg_name=`echo -e $managed_rg | cut -d  "/" -f5`
vnetResourceGroup=<VNET_RESOURCEGROUP_NAME>
vnetName=<VNET_NAME>
subnetName=<VNET_SUBNET_NAME>
location=<LOCATION>

#generate cloud config file
#validate this looks as expected after creation
cat <<EOF >> deploy/cloud.conf
{
"tenantId": "$tenantId",
"subscriptionId": $subId,
"resourceGroup": "$managed_rg_name",
"useManagedIdentityExtension": false,
"aadClientId": "$aadClientId",
"aadClientSecret": "$aadClientSecret",
"vnetResourceGroup": "$vnetResourceGroup",
"vnetName": "$vnetName",
"subnetName": "$subnetName",
"location": "$location"
}
EOF
cat deploy/cloud.conf
export AZURE_CLOUD_SECRET=`cat deploy/cloud.conf | base64 | awk '{printf $0}'; echo`
envsubst < ./azure-cloud-provider-spec.yaml > deploy/azure-cloud-provider.yaml
oc apply -f ./deploy/azure-cloud-provider.yaml

#validate secret creation
azure_cnf_secret=$(oc get secret azure-cloud-provider -n kube-system -o jsonpath="{.data.cloud-config}" | base64 --decode)
echo $azure_cnf_secret

### DEPLOY CSI DRIVER
#update permissions for csi driver service account
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:csi-azurefile-node-sa
helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
helm install azurefile-csi-driver azurefile-csi-driver/azurefile-csi-driver --namespace kube-system --version v1.10.0 --set controller.replicas=1

### Deploy Example
oc apply -f example-sc.yaml
oc apply -f example-pvc.yaml