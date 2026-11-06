locals {
  service_account_definition_name = "STACKIT Service Account"
  federation_definition_name      = "STACKIT Service Account Federation"
}

# The platform team publishes these two definitions. Trainers cannot create service accounts in the
# sandbox projects themselves, because that needs STACKIT organization access.
data "meshstack_building_block_definitions" "platform" {
  workspace_identifier = "meshcloud"

  lifecycle {
    postcondition {
      condition = alltrue([
        for name in [local.service_account_definition_name, local.federation_definition_name] :
        length([for bbd in self.building_block_definitions : bbd if bbd.spec.display_name == name]) == 1
      ])
      error_message = "Expected exactly one released '${local.service_account_definition_name}' and '${local.federation_definition_name}' definition owned by meshcloud."
    }
  }
}

locals {
  service_account_definition = one([for bbd in data.meshstack_building_block_definitions.platform.building_block_definitions : bbd if bbd.spec.display_name == local.service_account_definition_name])
  federation_definition      = one([for bbd in data.meshstack_building_block_definitions.platform.building_block_definitions : bbd if bbd.spec.display_name == local.federation_definition_name])
}

# A draft owned by the workshop workspace: only that workspace can order it, and the trainer can keep
# changing it.
resource "meshstack_building_block_definition" "baseline" {
  metadata = {
    owned_by_workspace = var.workspace_identifier
  }

  spec = {
    display_name        = "Workshop Baseline"
    description         = "Resources every workshop sandbox gets."
    target_type         = "TENANT_LEVEL"
    run_transparency    = true
    supported_platforms = [{ name = "STACKIT" }]
  }

  version_spec = {
    draft         = true
    deletion_mode = "DELETE"

    # Lets the baseline read an output of its federation parent.
    dependency_refs = [local.federation_definition.ref]

    implementation = {
      terraform = {
        terraform_version              = "1.12.5"
        repository_url                 = var.implementation.repository_url
        repository_path                = var.implementation.repository_path
        ref_name                       = var.implementation.ref_name
        async                          = false
        use_mesh_http_backend_fallback = true
      }
    }

    inputs = {
      project_id = {
        display_name    = "STACKIT Project ID"
        type            = "STRING"
        assignment_type = "PLATFORM_TENANT_ID"
      }

      # The STACKIT provider signs in through workload identity federation. The federation block,
      # the parent of each baseline block, names the service account that trusts this definition.
      STACKIT_SERVICE_ACCOUNT_EMAIL = {
        display_name    = "STACKIT Service Account Email"
        type            = "STRING"
        assignment_type = "BUILDING_BLOCK_OUTPUT"
        is_environment  = true
        argument        = jsonencode("${local.federation_definition.metadata.uuid}.service_account_email")
      }

      STACKIT_USE_OIDC = {
        display_name    = "STACKIT Use OIDC"
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        argument        = jsonencode("1")
      }

      STACKIT_FEDERATED_TOKEN_FILE = {
        display_name    = "STACKIT Federated Token File"
        type            = "STRING"
        assignment_type = "STATIC"
        is_environment  = true
        # The federation block trusts the token with the Azure audience.
        argument = jsonencode("/var/run/secrets/workload-identity/azure/token")
      }
    }
  }
}

resource "meshstack_building_block" "service_account" {
  for_each = var.sandboxes

  spec = {
    building_block_definition_version_ref = local.service_account_definition.version_latest_release
    display_name                          = "Workshop Baseline Service Account"
    target_ref                            = each.value.tenant_ref

    inputs = {
      service_account_name = { value = jsonencode("workshop-baseline") }
      roles                = { value = jsonencode(jsonencode(var.service_account_roles)) }
    }
  }
}

resource "meshstack_building_block" "federation" {
  for_each = var.sandboxes

  spec = {
    building_block_definition_version_ref = local.federation_definition.version_latest_release
    display_name                          = "Workshop Baseline Federation"
    target_ref                            = each.value.tenant_ref
    parent_building_block_refs            = [meshstack_building_block.service_account[each.key].ref]

    inputs = {
      service_account_email                = { value = meshstack_building_block.service_account[each.key].status.outputs["service_account_email"].value }
      federated_building_block_definitions = { value = jsonencode(jsonencode([meshstack_building_block_definition.baseline.metadata.uuid])) }
    }
  }
}

resource "meshstack_building_block" "baseline" {
  for_each = var.sandboxes

  spec = {
    # Carries the draft's content hash, so changing the baseline re-runs it in every sandbox.
    building_block_definition_version_ref = meshstack_building_block_definition.baseline.version_latest
    display_name                          = "Workshop Baseline"
    target_ref                            = each.value.tenant_ref
    parent_building_block_refs            = [meshstack_building_block.federation[each.key].ref]
    inputs                                = {}
  }
}
