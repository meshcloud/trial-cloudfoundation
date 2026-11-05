# STACKIT Kubernetes Engine

[`platform`](platform) orders the hub's STACKIT Kubernetes Platform reference architecture in the
workspace `meshcloud`. It owns the cluster `try-mesh`, Git, DNS, ingress, the container registry,
the meshPlatform `ske-namespace` with its landing zones and the starterkit definitions application
teams order.

## Access Kubernetes cluster

```bash
stackit auth login

stackit config set --project-id aa05c781-6026-49be-90e4-44d8314dec6d
stackit ske kubeconfig create try-mesh --login
```
