variable "workspace_identifier" {
  type        = string
  nullable    = false
  description = "Workshop workspace. It owns the baseline definition."
}

variable "sandboxes" {
  type = map(object({
    tenant_ref = object({
      kind = string
      uuid = string
    })
  }))
  nullable    = false
  description = "Sandboxes that get the baseline: the `sandboxes` output of the sandboxes module."
}

variable "service_account_roles" {
  type     = list(string)
  nullable = false
  # `editor` cannot manage IAM, which the example baseline does.
  default     = ["owner"]
  description = "STACKIT project roles of the service account the baseline runs as."
}

variable "implementation" {
  type = object({
    repository_url  = string
    repository_path = string
    ref_name        = string
  })
  nullable = false
  default = {
    repository_url  = "https://github.com/meshcloud/trial-cloudfoundation.git"
    repository_path = "foundations/meshstack-trial/platforms/stackit/workshop/baseline/buildingblock"
    ref_name        = "main"
  }
  description = "Terraform code of the baseline. Defaults to an example that creates a custom IAM role."
}
