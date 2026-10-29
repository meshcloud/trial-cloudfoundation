# STACKIT University offerings are only orderable from workspaces tagged like them, and only such a
# workspace can place a tenant on the STACKIT sandbox landing zone. Their tenant-level smoke tests
# order into the tenant here. The smoke test's API key acts here through its ADM_ permissions.
resource "meshstack_workspace" "smoke_test_stackit" {
  metadata = {
    name = "smoke-test-stackit"
    tags = { Company = ["stackit-university"] }
  }

  spec = {
    display_name = "Smoke Test STACKIT"
  }
}

resource "meshstack_payment_method" "smoke_test_stackit" {
  metadata = {
    name               = "smoke-test-stackit"
    owned_by_workspace = meshstack_workspace.smoke_test_stackit.metadata.name
  }

  spec = {
    display_name = "Smoke Test STACKIT"
  }
}

resource "meshstack_project" "smoke_test_stackit" {
  metadata = {
    name               = "smoke-test"
    owned_by_workspace = meshstack_workspace.smoke_test_stackit.metadata.name
  }

  spec = {
    display_name              = "Smoke Test"
    payment_method_identifier = meshstack_payment_method.smoke_test_stackit.metadata.name
  }
}

data "meshstack_landingzones" "stackit_sandbox" {
  identifier = "stackit-sandbox-default"
}

resource "meshstack_tenant" "smoke_test_stackit" {
  metadata = {
    owned_by_workspace = meshstack_workspace.smoke_test_stackit.metadata.name
    owned_by_project   = meshstack_project.smoke_test_stackit.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_landingzones.stackit_sandbox.landing_zones).spec.platform_ref
    landing_zone_ref = one(data.meshstack_landingzones.stackit_sandbox.landing_zones).ref
  }
}

output "stackit_tenant_uuid" {
  description = "Spelled out in ../smoke.hcl as the tenant STACKIT smoke tests order into."
  value       = meshstack_tenant.smoke_test_stackit.metadata.uuid
}
