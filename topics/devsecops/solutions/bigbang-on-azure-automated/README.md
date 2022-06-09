# Deploying BigBang on Azure using DSOPBuilder

This solution describes how to deploy BigBang to a Kubernetes Cluster running on Azure using the ***[DSOPBuilder](https://github.com/marlinspike/dsopbuilder)*** docker image.
DSOPBuilder is a docker container that contains a PyBuilder app that automates the deployment of BigBang from the ***[Repo1](https://repo1.dso.mil/platform-one/big-bang/customers/template/)*** template.

The install is fully documented in the DSOPBuilder Git repository at https://github.com/marlinspike/dsopbuilder.

## Recent Tests

| K8s Distribution | BigBang Version | Customer Template Version | Date Tested |
| :-- | :-- | :-- | --: |
| Rancher RKE2 | 1.30.1 | 1.19.0 | 6/9/2022 |
| Azure Kubernetes Service | 1.30.1 | 1.19.0 | 6/9/2022 |

## Known issues

