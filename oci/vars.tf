variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaamcax2cp7tbnootjb7rtkagz2avywcwcjrsxvomhnr3c4gbwi5cnq"
}

variable "user_ocid" {
  default   = "ocid1.user.oc1..aaaaaaaa6ybbeuexcnkdssrwf7ix7miew4frshwvn4o45inlhbjkqwetivyq"
  sensitive = true
}

variable "fingerprint" {
  default = "60:f7:6e:15:95:ed:a0:5d:83:0d:2e:dd:fc:81:82:b5"
}

variable "private_key_path" {
  default = "/Users/shibug/.ssh/id_rsa"
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKcin8GIfSSDgdOUaJaTWIRG4qDwQc26o9nYFg61UQCVaouCGbbK4b9HXk2H/zSOL5t1MopXYrbPlt1w8wjCvQtSnQ4/cEY1rjNo+tz8ZP+gznoxoShMWK+Bq2XwfWZLbsLQABIcqe7OEgOOkI0e1kXky9wa1F82D+6seNsNHYbpZVuVRNTsxMds0/z2F2bLZeYQbtxTIr3wGKu+IdCVlt4ldGNGjhp7LK1aT0PsnbNHYHUneiKfQmXyjyrre4WOH4q84XjowlZbynh1Of/p8K7s2E7wGePry3QxrAPiZhs6+fa3yjDNkCZiji9/qjCO/4tYGqT7Gu/xPMoxPXmIAQzZHcu1N2LCpHxxONGbCnq34/6MUx2cWS7FHtW3pNNgOZErigG+nlAgO0qjqOjpCxspl3juIagGCUPJQNRfsHtsXR3rzXHr23zlxHl2KGr0v6J0hYgLLb4p5DwBlHrlth+kf7SwR18wPPzn0K9m+Ubs7yeZyJacmouBMyCn/c7dmOMiB61pbOHVYw60bmKoHOmeAVCON+7lTNsjJqEqjV10heNJvbNjAh0mmLgNi8yRXL7BXZj6WxwetiVTfH3BFtmdaJ5HdoY6iYd+RBdtirqPneHqjyvfUAw+5hee22JonC0LlJcRz9oap0exZWb5zQQYnFmrsq6x6HKFuq8114DQ=="
}

variable "region" {
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
  default     = false
}

