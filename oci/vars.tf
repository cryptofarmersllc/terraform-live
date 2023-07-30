variable "tenancy_ocid" {
  default     = "ocid1.tenancy.oc1..aaaaaaaaggwwdjxka3nbyb2h5i4nyzw2keisjqwxoplmla2x7nt4aocrbj3a"
}

variable "user_ocid" {
  default     = "ocid1.user.oc1..aaaaaaaac7mcm3xnipmrqovkqikietxljyuumvpua2q3lpzhsx45vmza4juq"
  sensitive   = true
}

variable "fingerprint" {
  default     = "60:f7:6e:15:95:ed:a0:5d:83:0d:2e:dd:fc:81:82:b5"
}

variable "private_key_path" {
  default     = "/Users/shibug/.ssh/id_rsa"
}

variable "location" {
  description = "Data center location"
  default     = "us-ashburn-1"
}

variable "nb_executors" {
  type        = number
  description = "Number of executors"
  default     = 1
}

variable "cidrblock" {
  description = "CIDR block for this environment"
  default     = "10.0.0.0/16"
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

