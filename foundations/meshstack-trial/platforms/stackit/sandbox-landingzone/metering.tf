# --- STACKIT metering service account ---
#
# Read-only service account (org-level) used by meshStack metering to read
# project inventory from the Resource Manager API and cost data from the Cost API:
#   - https://resource-manager.api.stackit.cloud/v2/projects
#   - https://cost.api.stackit.cloud/v3/costs/{container_parent_id}
#
# STACKIT service accounts always live in a project, so a small dedicated
# project hosts the account even though its role assignments are org-scoped.
resource "stackit_resourcemanager_project" "metering" {
  name                = "trial-metering"
  owner_email         = local.stackit_owner_email
  parent_container_id = local.stackit_org
}

resource "stackit_service_account" "metering" {
  project_id = stackit_resourcemanager_project.metering.project_id
  name       = "trial-metering"
}

resource "stackit_service_account_key" "metering" {
  project_id            = stackit_resourcemanager_project.metering.project_id
  service_account_email = stackit_service_account.metering.email
}

resource "stackit_authorization_organization_role_assignment" "metering" {
  for_each = toset([
    "iaas.project.reader",
    "cost-management.cost.reader",
  ])

  resource_id = local.stackit_org
  role        = each.value
  subject     = stackit_service_account.metering.email
}

output "metering_service_account_email" {
  description = "Email of the STACKIT service account used for meshStack metering (reads Resource Manager and Cost API)."
  value       = stackit_service_account.metering.email
}

output "metering_service_account_key" {
  description = "STACKIT service account key JSON for the meshStack metering service account."
  value       = stackit_service_account_key.metering.json
  sensitive   = true
}


