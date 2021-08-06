variable "cidrblock" {
  description = "CIDR block for this environment"
  default     = "10.0.0.0/16"
}

variable "location" {
  description = "Data center location"
  default     = "East US 2"
}

variable "nb_validators" {
  type        = number
  description = "Number of validators"
  default     = 1
}

variable "admin_username" {
  description = "Administrator username for any OS"
  type        = string
  sensitive   = true
}

variable "keep_disk" {
  type        = bool
  description = "Prevents deleting storage disk when a VM is re-provisioned"
  default     = true
}
