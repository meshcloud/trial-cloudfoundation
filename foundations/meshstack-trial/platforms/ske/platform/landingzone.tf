locals {
  owning_workspace_identifier = "meshcloud"
  stackit_platform_uuid       = "b66e3542-5887-4d48-9f06-968dbc98d97c"
}

# Registered as drafts by the STACKIT sandbox landing zone in ../../stackit/sandbox-landingzone.
data "meshstack_building_block_definition" "stackit_project" {
  metadata = { uuid = "0e4ebeb3-b893-446a-b52a-3ab0c8294d71" }
}

data "meshstack_building_block_definition" "service_account" {
  metadata = { uuid = "2768b086-6739-43f8-b65e-a694abfc428f" }
}

data "meshstack_building_block_definition" "service_account_federation" {
  metadata = { uuid = "8bcbc976-3fa2-4879-b0d8-3ff2423f6c86" }
}
