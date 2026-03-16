variable "users" {
  description = "Email addresses of users to invite into the Microsoft Entra ID tenant as Global Administrators."
  type        = set(string)

  validation {
    condition     = alltrue([for email in var.users : can(regex("^[^@]+@[^@]+$", email))])
    error_message = "Every entry must be a valid email address."
  }
}
