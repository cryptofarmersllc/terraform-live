# We strongly recommend using the required_providers block to set the
# OCI Provider source and version being used
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

# Configure the Oracle Cloud Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# -----------------------------
# COMPARTMENT
# -----------------------------
resource "oci_identity_compartment" "eth_compartment" {

  compartment_id = var.tenancy_ocid
  description    = "Ethereum compartment"
  name           = "Ethereum"
  freeform_tags  = { "crypto" = "ethereum" }
}

# -----------------------------
# VIRTUAL CLOUD NETWORK
# -----------------------------
resource "oci_core_vcn" "vcn" {
  cidr_blocks    = [var.cidrblock]
  dns_label      = "vcn"
  compartment_id = oci_identity_compartment.eth_compartment.compartment_id
  display_name   = "vcn"
  freeform_tags  = { "crypto" = "ethereum" }
}

locals {
  eth_tags = {
    "crypto" = "ethereum"
  }
}

# -----------------------------
# INTERNET GATEWAY
# -----------------------------
resource "oci_core_internet_gateway" "ig" {
  #Required
  compartment_id = oci_identity_compartment.eth_compartment.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  enabled        = true
  display_name   = "Internet Gateway"
  freeform_tags  = { "crypto" = "ethereum" }
  route_table_id = oci_core_vcn.vcn.default_route_table_id
}

# -----------------------------
# ROUTE TABLE
# -----------------------------
/* resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  display_name               = "DefaultRouteTable"
  freeform_tags  = { "crypto" = "ethereum" }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
} */

# -----------------------------
# DATA SOURCES
# -----------------------------
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}
