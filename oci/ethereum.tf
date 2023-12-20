# -----------------------------
# SUBNETS
# -----------------------------
resource "oci_core_subnet" "ethereum" {
  cidr_block     = "10.0.2.0/24"
  compartment_id = oci_identity_compartment.eth_compartment.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "ethereum-subnet"
  dns_label      = "subnet"
  freeform_tags  = { "crypto" = "ethereum" }
}

# -----------------------------
# NETWORK SECURITY GROUPS
# -----------------------------
resource "oci_core_network_security_group" "ethereum" {
  compartment_id = oci_identity_compartment.eth_compartment.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "ethereum-nsg"
  freeform_tags  = { "crypto" = "ethereum" }
}

# --------------------------------------------------
# NETWORK SECURITY RULE
# --------------------------------------------------
# Allow ssh port access from Internet
resource "oci_core_network_security_group_security_rule" "ethereumIngress1122TCP" {
  network_security_group_id = oci_core_network_security_group.ethereum.id
  direction                 = "INGRESS"
  protocol                  = 6
  description               = "Executor Ingress Rule for TCP 1122"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  destination               = var.cidrblock
  tcp_options {
    source_port_range {
      min = 1
      max = 65535
    }
    destination_port_range {
      min = 1122
      max = 1122
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ethereumIngress13000TCP" {
  network_security_group_id = oci_core_network_security_group.ethereum.id
  direction                 = "INGRESS"
  protocol                  = 6
  description               = "Executor Ingress Rule for TCP 13000"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  destination               = var.cidrblock
  tcp_options {
    source_port_range {
      min = 1
      max = 65535
    }
    destination_port_range {
      min = 13000
      max = 13000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ethereumIngress30303TCP" {
  network_security_group_id = oci_core_network_security_group.ethereum.id
  direction                 = "INGRESS"
  protocol                  = 6
  description               = "Executor Ingress Rule for TCP 30303"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  destination               = var.cidrblock
  tcp_options {
    source_port_range {
      min = 1
      max = 65535
    }
    destination_port_range {
      min = 30303
      max = 30303
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ethereumIngress12000UDP" {
  network_security_group_id = oci_core_network_security_group.ethereum.id
  direction                 = "INGRESS"
  protocol                  = 17
  description               = "Executor Ingress Rule for UDP 12000"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  destination               = var.cidrblock
  udp_options {
    source_port_range {
      min = 1
      max = 65535
    }
    destination_port_range {
      min = 12000
      max = 12000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ethereumIngress30303UDP" {
  network_security_group_id = oci_core_network_security_group.ethereum.id
  direction                 = "INGRESS"
  protocol                  = 17
  description               = "Executor Ingress Rule for UDP 30303"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  destination               = var.cidrblock
  udp_options {
    source_port_range {
      min = 1
      max = 65535
    }
    destination_port_range {
      min = 30303
      max = 30303
    }
  }
}

# -----------------------------
# CORE INSTANCE
# -----------------------------
resource "oci_core_instance" "ethereum" {
  count               = var.nb_executors
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.eth_compartment.compartment_id
  display_name        = "use2lethereum"
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 32
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.ethereum.id
    display_name              = "Primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = format("use2lethereum%03dprod", count.index + 1)
  }
  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaa6blpytk5nu622uj7trevp7kjxihx4byt4q6botynbyjpknk7zwna"
    #ocid1.image.oc1.iad.aaaaaaaaeptstszfsrqlfapzmxbfhbp77gcd4ygiot7u7dpreosjjf4s2vka
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.default.rendered
  }

  freeform_tags = { "crypto" = "ethereum" }

  timeouts {
    create = "60m"
  }
}

# -----------------------------
# VOLUMES
# -----------------------------
resource "oci_core_volume" "ethereum_volume" {
  count               = var.nb_executors
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.eth_compartment.compartment_id
  display_name        = "eth_block${count.index}"
  size_in_gbs         = 2048
  vpus_per_gb         = 10
}

resource "oci_core_volume_attachment" "ethereum_volume_attach" {
  count           = var.nb_executors
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.ethereum[count.index].id
  volume_id       = oci_core_volume.ethereum_volume[count.index].id
  device          = count.index == 0 ? "/dev/oracleoci/oraclevdb" : ""

  # Set this to enable CHAP authentication for an ISCSI volume attachment. The oci_core_volume_attachment resource will
  # contain the CHAP authentication details via the "chap_secret" and "chap_username" attributes.
  use_chap = true
  # Set this to attach the volume as read-only.
  #is_read_only = true
}

# -----------------------------
# PUBLIC IPS
# -----------------------------
/* resource "oci_core_public_ip" "ethereum" {
  compartment_id = oci_identity_compartment.eth_compartment.compartment_id
  lifetime       = "Reserved"
  display_name   = "Ethereum public IP"
  freeform_tags  = { "crypto" = "ethereum" }
} */

# -----------------------------
# DATA SOURCES
# -----------------------------
data "oci_core_instance_devices" "ethereum" {
  count       = var.nb_executors
  instance_id = oci_core_instance.ethereum[count.index].id
}

# -----------------------------
# OUTPUTS
# -----------------------------
output "instance_private_ips" {
  value = [oci_core_instance.ethereum.*.private_ip]
}

output "instance_public_ips" {
  value = [oci_core_instance.ethereum.*.public_ip]
}

# Output all the devices for all instances
output "instance_devices" {
  value = [data.oci_core_instance_devices.ethereum.*.devices]
}