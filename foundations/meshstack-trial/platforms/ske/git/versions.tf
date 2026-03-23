terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.83"
    }
    forgejo = {
      source  = "svalabs/forgejo"
      version = "~> 1.3.0"
    }
  }
}
