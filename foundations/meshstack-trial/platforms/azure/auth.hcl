# Pins the Azure Entra ID tenant for all modules under platforms/azure/.
# Include this in every terragrunt.hcl that uses an azuread or azurerm provider
# so ARM_TENANT_ID is always set to the correct tenant regardless of the shell environment.
locals {
  tenant_id = "126d3c12-f458-42c3-9f94-cf29cc01dd77"
}

terraform {
  extra_arguments "azure_auth" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      ARM_TENANT_ID = local.tenant_id
    }
  }
}
