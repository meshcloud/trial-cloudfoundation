include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "meshstack" {
  config_path = "../meshstack"
  mock_outputs = {
    stackit_project_id = "00000000-0000-0000-0000-000000000000"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  default_region        = "eu01"
  service_account_key   = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
}
EOF
}

inputs = {
  stackit_project_id = dependency.meshstack.outputs.stackit_project_id
  cluster_name       = "try-mesh" # limited to 11 chars, to try-meshstack is too long
}
