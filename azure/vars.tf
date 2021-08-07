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
  default     = false
}

variable "users" {
  description = "A map of all user ids and keys to be created upon VM startup"

  default = {
    "harsha.id"   = "harsha"
    "harsha.name" = "Harsha Reddy"
    "harsha.key"  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyG3/lu5JjuLrT9KAbmmZvQGhppIuRcz131g2vNGAwRQ6YPa50PadEuog39LLvdPdRCrPyy5/KgT/EmXXjvdvZTSFNGzC0CFQ7hNzgU//bKh109a7c1H+CVdMeOLrmlFM4hzTGUU9eqKMqWUL746o6KWMXWs6mOjIByzjOOMKGGZhfKMVFjtSuKMrwmVb8Vaijk82xvCoh/DUPrR2xe5/Xl4F9VQHgIlFPkTOtDmlVKPkdWl4LHi7d0lQexnbxM5wGNg48Gd8VnzBJ3sKnksVRRPSHtm/lc5tSxmBDtP3aTjgPy5wfaFx8Jccqd47Dfzcenuz92fr8Yv2UbLAT/VCUD3uh8pOzznIpVTgRACs28RMStJ5POzl0sDTuHnAqSl0IX1ORRblVmVZvcfqFjhgzUHtqeLWNGCCxDo3K4zsgOazx2aWJCvOB6OEh213DD8ChPjPtOJLbmPU2xpvL6jH/kTWoGv2g7Sz5EnXfjmyRmvbF+lb0SutNllIwlFAgUTM="
  }
}
