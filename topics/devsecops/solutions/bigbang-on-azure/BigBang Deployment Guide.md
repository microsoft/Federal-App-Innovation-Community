**Prepared by: Microsoft Federal, DSOP SWAT Team**

# Step by Step: Installing Big Bang on Azure Government

https://microsoft-my.sharepoint.com/personal/scheruvu_microsoft_com/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fscheruvu%5Fmicrosoft%5Fcom%2FDocuments%2FRecordings%2F%28optional%29%20repo1%20BigBang%20MAG%20walkthrough%20deploy%2D20220404%5F150424%2DMeeting%20Recording%2Emp4&parent=%2Fpersonal%2Fscheruvu%5Fmicrosoft%5Fcom%2FDocuments%2FRecordings&ga=1


## Prerequisites
- A Kubernetes Cluster
- A Linux VM/machine with access to the internet and the Kubernetes cluster you want to deploy to
- A GitHub account.
- Preferably a development machine with VSCode so that you can more easily edit large YAML files; otherwise, using VI or Nano on the Linux VM works too

## Environment Setup

1. Set up an AKS Cluster in Azure (Government)
- I use 3 Nodes, with a min size of D4s_v3:
![enter image description here](https://i.imgur.com/Shei7mW.png)

You should expect an average of approx. 15% resource utilization by BB base tooling (graph shows Average in Blue and Max in Red):
![enter image description here](https://i.imgur.com/UBbMPs7.png)

2. Spin up a Ubuntu Linux VM and connect. Doesn't need to be a large SKU, so burstable is fine.
`ssh -i ~/.ssh/reulin.pem  azureuser@20.141.191.86`
3. Spin up an AKS cluster
4. You can now follow the P1 deploy file, OR the more streamlined instructions below: https://repo1.dso.mil/platform-one/big-bang/customers/template


### Install Prerequisites on Linux VM:
- **Kubectl**:
 ```
 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
 ```
- **Flux**: `curl -s https://fluxcd.io/install.sh | sudo bash`
- **curl**: `sudo apt update -y && sudo apt install curl -y`
- **Kustomize**:
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash 
chmod +x kustomize
sudo mv kustomize /usr/bin/kustomize
```
- **Terraform**:
```
wget https://releases.hashicorp.com/terraform/1.1.6/terraform_1.1.6_linux_amd64.zip
sudo apt update -y && sudo apt install unzip -y && unzip terraform_1.1.6_linux_amd64.zip && sudo mv terraform /usr/local/bin/ && rm terraform_1.1.6_linux_amd64.zip
```
- **Docker**: 
```
curl -fsSL https://get.docker.com | bash
sudo systemctl enable docker #enable = autostart the service on reboot
sudo systemctl start docker  #start = start the service now
```
- **Azurecli**: 
`curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
- **SOPS**:
```
curl -L https://github.com/mozilla/sops/releases/download/v3.7.2/sops-v3.7.2.linux > sops
chmod +x sops
sudo mv sops /usr/bin/sops
```
- **Helm**:
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

- **Log in to Azure US Gov on the VM**:
```
az cloud set --name AzureUsGovernment
az login
```

## Clone Repo onto your Development Environment

- Clone the repo (https://repo1.dso.mil/platform-one/big-bang/customers/template.git)
`git clone https://repo1.dso.mil/platform-one/big-bang/customers/template.git bb1`

## Edit the folder in VSCode
![enter image description here](https://i.imgur.com/MUIV3sK.png)

1. **dev/bigbang.yaml**: Copy the repo address and paste it in:
This declares a source for Flux so it knows where to pull from. Edit the URL and Branch.
![enter image description here](https://i.imgur.com/FiHSku9.png)

![enter image description here](https://i.imgur.com/LeM2UUx.png)

2. **base/bigbang-dev-cert.yaml** Edit the certificate file
Copy this text below, and place in the file as shown. Then, replace the placeholder text with the proper values as required:
```
registryCredentials:
- registry: registry1.dso.mil
username: replace-with-your-iron-bank-user=
password: replace-with-your-iron-bank-personal-access-token
```
![enter image description here](https://i.imgur.com/7FXXdjh.png)

3. Now push the code to the repo

## Clone the repo on the Virtual Machine
This gets all the changes we've made on the Mac/PC down to the VM. Awesome. Rocking so far!

## Create PGP Encryption Key
On the Linux VM, perform the following steps:
- Create the PGP Encryption Key
***Important*** Do NOT ADD A PASSPHRASE! (Because Flux can't type when it syncs)
```export fp=`gpg --quick-generate-key bigbang-sops rsa4096 encr | sed -e 's/ *//;2q;d;'` ```
Verify that the key is created via:
```
echo $fp
0E5AC9A71A1885B5A0B45BD9BA38E87B381ED3D0
```
- Configure .sops.yaml (we're using the $fp variable created above):
```
sed -i "s/pgp: FALSE_KEY_HERE/pgp: ${fp}/" .sops.yaml
```
*.sops.yaml should look like this now:*
![enter image description here](https://i.imgur.com/HgozHuR.png)

This should match what gpg stores in your keystore: `gpg --list-keys`

## Add TLS Certificates
Move to the "base" folder.
- Move BB Certs to secrets.enc.yaml. These are used by flux to do future pulls from GitHub for reconciliations:
`sops -e bigbang-dev-cert.yaml > secrets.enc.yaml`

If you *cat* secrets.enc.yaml, you should see the sops-encrypted version of bigbang-dev-cert.yaml. This is "safe" to store on GitHub; that's what SOPS does for you.

## Check in all the local changes from the VM
We've made several changes on the VM. Now we check them all in at once. The changes should have been to two files: .sops.yaml and base/secrets.enc.yaml.

Go to the base folder
```
git add .
git commit -m "all"
git push
```

## Deploy Namespaces and Flux
Finally, we're deploying!
- Create namespace 'bigbang':
`kubectl create namespace bigbang`
- Get the Credentials for the AKS Cluster
`az aks get-credentials --name bigbang-demo --resource-group bigbang`
- Provide Kubernetes the secrets to be able to decrypt the sops-encrypted files
`gpg --export-secret-key --armor ${fp} | kubectl create secret generic sops-gpg -n bigbang --from-file=bigbangkey.asc=/dev/stdin`
- Create imagePullSecrets for Flux
`
kubectl create namespace flux-system`

For this next command, pace your *docker-username* and *docker-password* with your **IronBank Username** and **Registry1 CLI Secret**.
![enter image description here](https://i.imgur.com/lbU0NBN.png)

```
kubectl create secret docker-registry private-registry --docker-server=registry1.dso.mil --docker-username=rcleetus --docker-password=FpNncaeCATywvNWRjlb4s2aAuHQsdU9U -n flux-system
```

- Create Git credentials for Flux (so that it can access your Git repo):
For this command, replace *username* with your **GitHub Username**, and *password* with your **GitHub Personal Access Token**.
```
kubectl create secret generic private-git --from-literal=username=shuffereu --from-literal=password=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 -n bigbang
```
- **Deploy Flux**. Once we give it the bigbang yaml, it'll reconcile everything:
Instead of calling Kustomize directly, I've used Kustomize via Kubectl
```
kubectl apply -k https://repo1.dso.mil/platform-one/big-bang/bigbang.git//base/flux?ref=1.29.0
```
![enter image description here](https://i.imgur.com/PaDtmkT.png)
Then verify that Flux is in fact deployed:
`kubectl get deploy -o name -n flux-system | xargs -n1 -t kubectl rollout status -n flux-system`

![enter image description here](https://i.imgur.com/d0DU97F.png)

## Apply Big Bang Deployment Manifest
Switch to the *dev* folder.
- Apply the bigbang.yaml file:
`kubectl apply -f bigbang.yaml`

You should be able to see the gitrepositories get synched: `kubectl apply -f bigbang.yaml`
![enter image description here](https://i.imgur.com/UXjW6ob.png)
- Watch as the pods get created: `watch kubectl get hr,po -A`
![enter image description here](https://i.imgur.com/hl0wiW5.png)
**Note:** In Azure Government, the gatekeeper-system pods will fail. There's an easy workaround.

- Get the status of the bigbang kustomization: `k get -n bigbang kustomizations`
![enter image description here](https://i.imgur.com/6hApWCO.png)
- In Azure Government, gatekeeper will fail like this: `watch kubectl get hr,po -A`
![enter image description here](https://i.imgur.com/4cr7eaC.png)

To Fix this:
- First list all the secrets: `k get secret -n bigbang`
![enter image description here](https://i.imgur.com/0BAqNZj.png)

**Then follow these steps:**
1. Stop Flux from synching gatekeeper: `flux suspend hr -n bigbang gatekeeper`
2. Delete the Gatekeeper secret: `k delete secret sh.helm.release.v1.gatekeeper-system-gatekeeper.v1 -n bigbang`
3. Resume synching gatekeeper: `flux resume hr -n bigbang gatekeeper`
4. All the pods should start to come in
![enter image description here](https://i.imgur.com/31nn1dJ.png)

## Verify Complete
This is how to verify that you're actually done-done.

From the terminal:
```
`watch kubectl get hr,po -A`
```
![enter image description here](https://i.imgur.com/H6Exf9r.png)

- Note that Release reconciliation has succeeded for all the components with no failures
