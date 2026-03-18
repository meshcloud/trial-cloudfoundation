include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "auth" {
  path = find_in_parent_folders("auth.hcl")
}

inputs = {
  users = [
    "fnowarre@meshcloud.io",
    "jrudolph@meshcloud.io",
    "hdettmer@meshcloud.io",
    "agrub@meshcloud.io",
    "jdburger@meshcloud.io"
  ]
}
