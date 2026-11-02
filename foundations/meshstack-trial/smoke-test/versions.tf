terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.26.8"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
