# Pins the Azure subscription and tenant for all modules under aks/idp/.
# Included by every terragrunt.hcl that uses an Azure provider so the
# ARM_* env vars are always set to the correct values regardless of the shell environment.
locals {
  subscription_id = "1567cc6d-6c8f-4dac-a64f-8f7293116490"
  tenant_id       = "126d3c12-f458-42c3-9f94-cf29cc01dd77"
}

terraform {
  extra_arguments "azure_env" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      ARM_SUBSCRIPTION_ID = local.subscription_id
      ARM_TENANT_ID       = local.tenant_id
    }
  }
}
