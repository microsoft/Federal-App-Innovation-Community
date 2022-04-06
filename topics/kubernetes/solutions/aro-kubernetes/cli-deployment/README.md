# ARO Quick Build

The following script will run a quick deployment of ARO for you, setting up a VNET with two subnets and an associated cluster.

Take a look at the parameters in the script if you want to change any properties.

The script looks for a `pull-secret.txt` file in the folder - you can generate a Red Hat pull secret by following [these instructions](https://docs.microsoft.com/en-us/azure/openshift/tutorial-create-cluster#get-a-red-hat-pull-secret-optional).

# Deploy

```bash
az cloud set --name <AzureCloud | AzureUSGovernment>
az login --use-device-code

./aro-quick-build.sh
```

# Reference Repo
1. https://github.com/stuartatmicrosoft/azure-aro