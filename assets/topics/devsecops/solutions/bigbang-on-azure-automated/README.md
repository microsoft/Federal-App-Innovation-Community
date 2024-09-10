# Deploying BigBang on Azure using DSOPBuilder

This solution describes how to deploy BigBang to a Kubernetes Cluster running on Azure using the ***[DSOPBuilder](https://github.com/marlinspike/dsopbuilder)*** docker image.
DSOPBuilder is a docker container that contains a PyBuilder app that automates the deployment of BigBang from the ***[Repo1](https://repo1.dso.mil/platform-one/big-bang/customers/template/)*** template.

The install is fully documented in the DSOPBuilder Git repository at https://github.com/marlinspike/dsopbuilder.

## Recent Tests

| K8s Distribution | BigBang Version | Customer Template Version | Date Tested |
| :-- | :-- | :-- | --: |
| Rancher RKE2 | 1.36.0 | 1.12.0 | 7/10/2022[*](#monitoring-reconciliation-fails-on-rke2) |
| Azure Kubernetes Service | 1.30.1 | 1.9.0 | 6/9/2022[*](#1301-1190-gatekeeper-on-aks) |

## Known issues

### Monitoring Reconciliation Fails on RKE2

Symptom: During reconciliation, `monitoring` is unable to reconcile with the following error message:

```bash
Helm install failed: ServiceMonitor.monitoring.coreos.com "monitoring-monitoring-kube-kube-state-metrics" is invalid: 
spec.endpoints.honorLabels: Invalid value: "null": spec.endpoints.honorLabels in body must be of type boolean: "null"
```

This is documented in [issue #66](https://repo1.dso.mil/platform-one/big-bang/apps/core/monitoring/-/issues/66) in the big-bang monitoring source repository.

The workaround proposed in the write-up of this issue allows monitoring to reconcile successfully.

Add the following to `working/dsop_rke2/dev/configmap.yaml` and push the changes to your git repository

```yaml
monitoring:
  values:
  <---- ADD BELOW HERE ---->
    kubeStateMetrics:
      serviceMonitor:
        honorLabels: true
```

### 1.30.1-1.19.0 Gatekeeper on AKS

Symptom: During reconciliation, `gatekeeper` is unable to fully reconcile without intervention, resulting in `upgrade retries exhausted`.

```bash
$ kubectl get hr gatekeeper -n bigbang

NAME         READY   STATUS                      AGE
gatekeeper   False   upgrade retries exhausted   106m
```

To get beyond this issue, the `gatekeeper.v1` secret in the `bigbang` namespace must be deleted, and flux must be restarted. See below:

```bash

## Verify that the secret exists; json output should read "status": "pending-install"
kubectl get secret -n bigbang
kubectl get secret sh.helm.release.v1.gatekeeper-system-gatekeeper.v1 -n bigbang -o jsonpath="{.data.release }"|base64 -d | base64 -d|gunzip -c | jq '.info'

## Delete the secret
kubectl delete secret sh.helm.release.v1.gatekeeper-system-gatekeeper.v1 -n bigbang

## Restart flux
flux suspend hr -n bigbang gatekeeper
sleep 30
flux resume hr -n bigbang gatekeeper &
```
