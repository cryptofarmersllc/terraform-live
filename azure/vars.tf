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
  default     = 3
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

variable "users" {
  description = "A map of all user ids and keys to be created upon VM startup"

  default = {
    "harsha.id"   = "harsha"
    "harsha.name" = "Harsha Reddy"
    "harsha.key"  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyG3/lu5JjuLrT9KAbmmZvQGhppIuRcz131g2vNGAwRQ6YPa50PadEuog39LLvdPdRCrPyy5/KgT/EmXXjvdvZTSFNGzC0CFQ7hNzgU//bKh109a7c1H+CVdMeOLrmlFM4hzTGUU9eqKMqWUL746o6KWMXWs6mOjIByzjOOMKGGZhfKMVFjtSuKMrwmVb8Vaijk82xvCoh/DUPrR2xe5/Xl4F9VQHgIlFPkTOtDmlVKPkdWl4LHi7d0lQexnbxM5wGNg48Gd8VnzBJ3sKnksVRRPSHtm/lc5tSxmBDtP3aTjgPy5wfaFx8Jccqd47Dfzcenuz92fr8Yv2UbLAT/VCUD3uh8pOzznIpVTgRACs28RMStJ5POzl0sDTuHnAqSl0IX1ORRblVmVZvcfqFjhgzUHtqeLWNGCCxDo3K4zsgOazx2aWJCvOB6OEh213DD8ChPjPtOJLbmPU2xpvL6jH/kTWoGv2g7Sz5EnXfjmyRmvbF+lb0SutNllIwlFAgUTM="
    "jyothi.id"   = "jyothi"
    "jyothi.name" = "Jyothi Goudar"
    "jyothi.key"  = "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCveseXBatXDy4o0El27GDlL3EIr/Ol62if62ihGw3qOfM3O1vQpspAYrJ6ZERD0F+vcNSbQ+GvLxDLt6qYSTlRShqNzGHAp09aN4E67gU6vNQGtzuyZCHgjC3mHEijlaK5iFsCDR8CMigRQ8A925ilzZahvGvSY7+5FItJ8acAH4JLzYCnIc0Dck64wX2Y0RQH4uSH3bxr/Hd+jRHL6qYkgf2FF5G2I0Mii/9Uw36R5Vew9fKZ/LCrJWjCyUDflzCwC2ZGYtNR8JreeOeE2aHTU80t7RWCBF1QsxTJ360ouqJ1ZmmKoRoZNneKmjwgdgwhVBneHsGwdyM+8nfmjC/6fs8u8P+7pysHHvtoC5gJSObRfvWkL2lkV9JcOR1sX2GZzCmw/hyP8vWUnAUXKZNSRQ0+irHPn6XC5uO1aAqaKYMkgr5QJhfBZ54JvhSFbVWLAKBuN37g+XdmHZEFvHJlVIkR5nCqe2IpoI1R+H5rlY/wNwyRFdpJTr3VQcGcmzk="
  }
}
