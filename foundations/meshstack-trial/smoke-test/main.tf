# No Company tag: the smoke test orders what an untagged trial workspace can order.
resource "meshstack_workspace" "smoke_test" {
  metadata = {
    name = "smoke-test"
    tags = {}
  }

  spec = {
    display_name = "Smoke Test"
  }
}

resource "meshstack_api_key" "smoke_test" {
  metadata = {
    owned_by_workspace = meshstack_workspace.smoke_test.metadata.name
  }

  spec = {
    display_name = "smoke-test"
    permissions = [
      "ADM_BUILDINGBLOCKRUN_LIST",
      "BUILDINGBLOCKDEFINITION_LIST",
      "BUILDINGBLOCK_DELETE",
      "BUILDINGBLOCK_LIST",
      "BUILDINGBLOCK_SAVE",
      "PROJECT_DELETE",
      "PROJECT_LIST",
      "PROJECT_SAVE",
      "PROJECTPRINCIPALROLE_DELETE",
      "PROJECTPRINCIPALROLE_LIST",
      "PROJECTPRINCIPALROLE_SAVE",
      "TENANT_DELETE",
      "TENANT_LIST",
      "TENANT_SAVE",
    ]
    # Changing the date rotates the secret, and the Actions secret below follows it.
    expires_at = "2027-10-01"
  }
}

resource "github_actions_environment_secret" "meshstack_api_secret" {
  repository      = "trial-cloudfoundation"
  environment     = "smoke-test"
  secret_name     = "MESHSTACK_API_SECRET"
  plaintext_value = meshstack_api_key.smoke_test.status.client_secret
}

output "api_key_client_id" {
  value = meshstack_api_key.smoke_test.status.client_id
}
