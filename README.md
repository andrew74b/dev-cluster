# dev-cluster

A reference project used to deploy applications onto a Kubernetes cluster.

## Getting Started

This project uses ArgoCD to deploy all the necessary applications, so familiarity with ArgoCD is important.

## Microk8s Setup

Follow the instructions for a setting up a cluster using Microk8s.

### Enable Cluster Addons

Enable MetalLB with a specific AddressPool

```shell
microk8s enable metallb:192.168.1.240-192.168.1.244
```

Enable Ingress with a default cert

```shell
microk8s enable ingress:default-ssl-certificate="default/andrew74b-tls"
```

Enable Metrics Server for `kubectl top`

```shell
microk8s enable metrics-server
```

## Deploy SOPS Secrets Operator

Prior to deploying ArgoCD, the SOPS Secrets Operator must be deployed to handle any encrypted secrets.

Export the `age` key file path used to encrypt the secrets.

```shell
export SOPS_AGE_KEY_FILE=/path/to/age-key.txt
```

Install the SOPS Secrets Operator repo.

```shell
helm repo add sops-secrets-operator https://isindir.github.io/sops-secrets-operator
```

Deploy the Helm chart.

```shell
helm install sops sops-secrets-operator/sops-secrets-operator --create-namespace --namespace sops --version 0.27.1 -f sops/values.yaml
```

Create a secret in the `sops` namespace referencing the `age` key file path.

```shell
kubectl create secret generic -n sops age-key --from-file=keys.txt=$SOPS_AGE_KEY_FILE
```

Verify all the SOPS Secrets Operator pods are in the `Running` state.

```shell
kubectl get -n sops pods --watch
```

## Deploy ArgoCD

Be sure that the SOPS Secrets Operator is deployed prior to deploying ArgoCD.

```shell
kubectl apply -k argocd --server-side
```

Verify all the ArgoCD pods are in the `Running` state.

```shell
kubectl get -n argocd pods --watch
```

Optionally, retrieve the `admin` user password to view or troubleshoot the ArgoCD deployment via the browser.

```shell
kubectl get -n argocd secrets argocd-initial-admin-secret --template '{{.data.password | base64decode | printf "%s\n"}}'
```

Navigate to http://192.168.1.241 and log in with the `admin` user and the password found above.

## Deploy App of Apps

This project uses an app of apps pattern using ArgoCD to deploy multiple applications in waves. To deploy the root application:

```shell
kubectl apply -f root-app.yaml
```

View the status of the ArgoCD applications via `kubectl`

```shell
watch kubectl get -n argocd applications.argoproj.io
```

View all services of type `LoadBalancer`

```shell
kubectl get svc -A --field-selector spec.type=LoadBalancer
```

## Remove the App

By default the application is syncing and the operation must be terminated prior to deletion:
- Select **Applications** in the menu
- Select **argocd-cluster** application
- Select **Sync Status**
- Click on **Terminate** and choose **OK** when asked, "Are you sure you want to terminate operation?"

Delete the app along with any resources that specify a finalizer

```shell
kubectl delete -f root-app.yaml
```

To keep any allocated resources, terminate and disable the sync policy then remove the finalizer.

```shell
kubectl patch -n argocd app <app> --type=merge -p '{"metadata":{"finalizers":null}}'
```
