terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.23.1"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.102"
    }
  }
}

provider "stackit" {
  experiments         = ["iam"] # Required for authorization resources
  service_account_key = var.stackit_service_account_key
}
