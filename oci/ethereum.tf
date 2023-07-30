# -----------------------------
# SUBNETS
# -----------------------------
resource "oci_core_subnet" "ethereum" {
    #Required
    cidr_block = "10.0.2.0/24"
    compartment_id = oci_identity_compartment.eth_compartment.compartment_id
    vcn_id = oci_core_vcn.vcn.id
    display_name = "ethereum-subnet"
    dns_label = "subnet"
    freeform_tags = {"crypto" = "ethereum"}
}

# --------------------------------------------------
# NETWORK SECURITY List
# --------------------------------------------------
# Allow ssh port access from Internet

resource "oci_core_security_list" "ethereum_security_list" {
    #Required
    compartment_id = oci_identity_compartment.eth_compartment.compartment_id
    vcn_id = oci_core_vcn.vcn.id
    display_name = "Ethereum Security List"
    egress_security_rules {
        #Required
        destination = var.security_list_egress_security_rules_destination
        protocol = var.security_list_egress_security_rules_protocol

        #Optional
        description = var.security_list_egress_security_rules_description
        destination_type = var.security_list_egress_security_rules_destination_type
        icmp_options {
            #Required
            type = var.security_list_egress_security_rules_icmp_options_type

            #Optional
            code = var.security_list_egress_security_rules_icmp_options_code
        }
        stateless = var.security_list_egress_security_rules_stateless
        tcp_options {

            #Optional
            max = var.security_list_egress_security_rules_tcp_options_destination_port_range_max
            min = var.security_list_egress_security_rules_tcp_options_destination_port_range_min
            source_port_range {
                #Required
                max = var.security_list_egress_security_rules_tcp_options_source_port_range_max
                min = var.security_list_egress_security_rules_tcp_options_source_port_range_min
            }
        }
        udp_options {

            #Optional
            max = var.security_list_egress_security_rules_udp_options_destination_port_range_max
            min = var.security_list_egress_security_rules_udp_options_destination_port_range_min
            source_port_range {
                #Required
                max = var.security_list_egress_security_rules_udp_options_source_port_range_max
                min = var.security_list_egress_security_rules_udp_options_source_port_range_min
            }
        }
    }
    freeform_tags = {"Department"= "Finance"}
    ingress_security_rules {
        #Required
        protocol = var.security_list_ingress_security_rules_protocol
        source = var.security_list_ingress_security_rules_source

        #Optional
        description = var.security_list_ingress_security_rules_description
        icmp_options {
            #Required
            type = var.security_list_ingress_security_rules_icmp_options_type

            #Optional
            code = var.security_list_ingress_security_rules_icmp_options_code
        }
        source_type = var.security_list_ingress_security_rules_source_type
        stateless = var.security_list_ingress_security_rules_stateless
        tcp_options {

            #Optional
            max = var.security_list_ingress_security_rules_tcp_options_destination_port_range_max
            min = var.security_list_ingress_security_rules_tcp_options_destination_port_range_min
            source_port_range {
                #Required
                max = var.security_list_ingress_security_rules_tcp_options_source_port_range_max
                min = var.security_list_ingress_security_rules_tcp_options_source_port_range_min
            }
        }
        udp_options {

            #Optional
            max = var.security_list_ingress_security_rules_udp_options_destination_port_range_max
            min = var.security_list_ingress_security_rules_udp_options_destination_port_range_min
            source_port_range {
                #Required
                max = var.security_list_ingress_security_rules_udp_options_source_port_range_max
                min = var.security_list_ingress_security_rules_udp_options_source_port_range_min
            }
        }
    }
}