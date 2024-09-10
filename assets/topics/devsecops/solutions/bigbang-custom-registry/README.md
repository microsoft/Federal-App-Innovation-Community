# Using a custom registry on BigBang
Part of the security in BigBang is Gatekeeper. On initial install Gatekeeper blocks images that are not hosted in registry.dso.mil or registry1.dso.mil. If you are using your own private registry, Gatekeeper will block your images and your apps will not deploy. 

In this walkthrough we will add a constraint configuration and have Flux update your cluster to allow another registry.


## Introduction

[![Intro](https://img.youtube.com/vi/wl4BXMZpSPg/1.jpg)](https://youtu.be/wl4BXMZpSPg)


## Step 1
[![Intro](https://img.youtube.com/vi/hTiwthQVJ94/1.jpg)](https://youtu.be/hTiwthQVJ94)

Confirm what is in your k8sallowedrepos

```bash
kubectl edit k8sallowedrepos.constraints.gatekeeper.sh/allowed-docker-registries
```


## Step 2
[![Intro](https://img.youtube.com/vi/Gso_ufZMLuY/1.jpg)](https://youtu.be/Gso_ufZMLuY)

You are going to create a [constraint.yaml](constraint.yaml) with your allowes repos. This should be placed in your env dir such as Dev or Prod.

```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: allowed-docker-registries
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    repos:
      - "registry.dso.mil"
      - "registry1.dso.mil"
      - "docker.io"
```

Then add a kustomization to kustomization.yaml
```
bases:
- ../base
configMapGenerator:
  - name: environment
    behavior: merge
    files:
      - values.yaml=configmap.yaml

resources:
  - constraint.yaml
```


## Step 3
[![Intro](https://img.youtube.com/vi/U-RFD-X_kaI/1.jpg)](https://youtu.be/U-RFD-X_kaI)

Confirm you can deploy an image from the registry. Remember kids, if you can't deploy neither can Flux!














