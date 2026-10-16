locals {
  sandbox_numbers = [for i in range(1, var.sandbox_count + 1) : format("%02d", i)]
}

# Looked up rather than taken as given, so a typo or a missing object fails the plan instead of
# leaving projects without tenants halfway through an apply. The landing zone also names its
# platform, so the trainer never needs to know a platform uuid.
data "meshstack_landingzones" "sandbox" {
  identifier = var.landing_zone_name

  lifecycle {
    postcondition {
      condition     = length(self.landing_zones) == 1
      error_message = "Expected exactly one landing zone named '${var.landing_zone_name}', found ${length(self.landing_zones)}."
    }
  }
}

data "meshstack_payment_method" "workshop" {
  metadata = {
    name               = coalesce(var.payment_method_identifier, "${var.workspace_identifier}-payment-method")
    owned_by_workspace = var.workspace_identifier
  }
}

locals {
  landing_zone = one(data.meshstack_landingzones.sandbox.landing_zones)
}

resource "meshstack_project" "sandbox" {
  for_each = toset(local.sandbox_numbers)

  metadata = {
    name               = "${var.project_identifier_prefix}-${each.key}"
    owned_by_workspace = var.workspace_identifier
  }

  spec = {
    display_name              = "Sandbox ${each.key}"
    payment_method_identifier = data.meshstack_payment_method.workshop.metadata.name
  }
}

resource "meshstack_tenant" "sandbox" {
  for_each = meshstack_project.sandbox

  metadata = {
    owned_by_workspace = var.workspace_identifier
    owned_by_project   = each.value.metadata.name
  }

  spec = {
    platform_ref     = local.landing_zone.spec.platform_ref
    landing_zone_ref = local.landing_zone.ref
  }
}
