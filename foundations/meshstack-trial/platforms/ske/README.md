# STACKIT Kubernetes Engine

[`platform`](platform) orders the hub's STACKIT Kubernetes Platform reference architecture in the
workspace `meshcloud`. It owns the cluster `try-mesh`, Git, DNS, ingress, the container registry,
the meshPlatform `ske-namespace` with its landing zones and the starterkit definitions application
teams order.

[`platform/e2e`](platform/e2e) is its nightly smoke test: it orders the published `SKE Starterkit`
into the workspace `smoke-test` and checks that both app endpoints serve over TLS. It reads the hub
ref from [`platform/hub.hcl`](platform/hub.hcl), so it follows every bump of the platform.

## Access Kubernetes cluster

```bash
stackit auth login

stackit config set --project-id aa05c781-6026-49be-90e4-44d8314dec6d
stackit ske kubeconfig create try-mesh --login
```
