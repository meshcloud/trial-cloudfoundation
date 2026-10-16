# Workshop trainers own a baseline building block definition in their workshop workspace, but get no
# STACKIT organization access. These two released definitions let them create a service account in
# each sandbox project and federate it to their baseline definition, so its runs need no key.
variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

locals {
  stackit_org         = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  stackit_owner_email = "stackit@meshcloud.io"

  meshstack = {
    owning_workspace_identifier = "meshcloud"
    # Must intersect with meshcloud's own Company tag. It also limits ordering to STACKIT University
    # workspaces, whose sandbox project admins are STACKIT owners already.
    tags = { Company = ["stackit-university"] }
  }
}

# STACKIT service accounts always live in a project, even when their role assignments are org-scoped.
resource "stackit_resourcemanager_project" "backplane" {
  name                = "trial-bb-backplane"
  owner_email         = local.stackit_owner_email
  parent_container_id = local.stackit_org
}

module "service_account" {
  source = "github.com/meshcloud/meshstack-hub//modules/stackit/service-account?ref=${var.hub.git_ref}"

  stackit_organization_id = local.stackit_org
  stackit_project_id      = stackit_resourcemanager_project.backplane.project_id
  # A baseline that manages IAM in a sandbox needs more than `editor`.
  stackit_assignable_roles = ["reader", "editor", "owner"]

  meshstack = local.meshstack
  hub       = var.hub
}

module "service_account_federation" {
  source = "github.com/meshcloud/meshstack-hub//modules/stackit/service-account-federation?ref=${var.hub.git_ref}"

  stackit_organization_id = local.stackit_org
  stackit_project_id      = stackit_resourcemanager_project.backplane.project_id

  meshstack = local.meshstack
  hub       = var.hub
}

output "building_block_definitions" {
  value = {
    service_account            = module.service_account.building_block_definition
    service_account_federation = module.service_account_federation.building_block_definition
  }
}
