terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.28.2 is the first release whose tenant destroy waits with `wait_for_completion = false`.
      version = ">= 0.28.2"
    }
  }
}
