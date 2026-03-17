include "common" {
  path = find_in_parent_folders("common.hcl")
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
