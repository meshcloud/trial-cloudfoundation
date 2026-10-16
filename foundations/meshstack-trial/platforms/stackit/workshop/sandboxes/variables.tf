variable "workspace_identifier" {
  type        = string
  nullable    = false
  description = "Workshop workspace the sandboxes are created in, as created by the STACKIT University workspace starterkit."
}

variable "sandbox_count" {
  type        = number
  nullable    = false
  description = "Number of sandboxes. Each one is a meshProject with a STACKIT sandbox tenant. Lowering it destroys the sandboxes with the highest numbers, together with their STACKIT projects."

  validation {
    condition     = var.sandbox_count >= 1 && var.sandbox_count <= 30 && floor(var.sandbox_count) == var.sandbox_count
    error_message = "sandbox_count must be a whole number from 1 to 30."
  }
}

variable "project_identifier_prefix" {
  type        = string
  nullable    = false
  default     = "sandbox"
  description = "Sandbox N gets the meshProject identifier `<prefix>-NN`."
}

variable "payment_method_identifier" {
  type        = string
  default     = null
  description = "Payment method the sandbox projects are billed to. Defaults to the one the workspace starterkit created for the workshop workspace."
}

variable "landing_zone_name" {
  type        = string
  nullable    = false
  default     = "stackit-sandbox-default"
  description = "Identifier of the landing zone the sandbox tenants are placed in. Defaults to the STACKIT sandbox landing zone of try.meshstack.io."
}
