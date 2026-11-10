variable "hub_ref" {
  type = string
}

variable "runner_ref" {
  type = object({ kind = string, uuid = string })
}
