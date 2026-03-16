---
id: azure
name: Azure
azure:
  aadTenantId: 126d3c12-f458-42c3-9f94-cf29cc01dd77
  subscriptionId: 1567cc6d-6c8f-4dac-a64f-8f7293116490
---

# Azure

This is the Azure platform for meshStack Trial. Currently only includes the subscription (manually created - 1567cc6d-6c8f-4dac-a64f-8f7293116490) to host the AKS cluster for the AKS starterkit.

Global administrators for the Microsoft Entra ID tenant (126d3c12-f458-42c3-9f94-cf29cc01dd77) can be invited in the [bootstrap module](bootstrap/README.md). Add their email addresses to the `users` input in terragrunt.hcl for the bootstrap module, then apply it to invite them as global administrators.

Future:

- org and management group structure, policies.
- meshStack integration for tenant provisioning.
- proper PAM
