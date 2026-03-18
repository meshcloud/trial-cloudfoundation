include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "auth" {
  path = find_in_parent_folders("auth.hcl")
}

inputs = {
  display_name  = "try.meshstack.io"
  redirect_uris = ["https://sso.try.meshstack.io/auth/realms/meshfed/broker/microsoft/endpoint"]
}
