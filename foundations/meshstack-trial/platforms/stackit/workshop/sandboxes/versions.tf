terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.26.2 is the first release whose `profile` login acts in the workspace it names.
      version = ">= 0.26.2"
    }
  }
}
