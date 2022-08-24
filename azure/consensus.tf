# -----------------------------
# SUBNETS
# -----------------------------
resource "azurerm_subnet" "validator" {
  name                 = "validator-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "shared" {
  name                 = "shared-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.1.0/27"]
}

# -----------------------------
# NETWORK SECURITY GROUPS
# -----------------------------
resource "azurerm_network_security_group" "validator" {
  name                = "nsg-validator"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.eth_tags
}

resource "azurerm_subnet_network_security_group_association" "validator" {
  subnet_id                 = azurerm_subnet.validator.id
  network_security_group_id = azurerm_network_security_group.validator.id
}

resource "azurerm_network_security_group" "shared" {
  name                = "nsg-shared"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.eth_tags
}

resource "azurerm_subnet_network_security_group_association" "shared" {
  subnet_id                 = azurerm_subnet.shared.id
  network_security_group_id = azurerm_network_security_group.shared.id
}

# --------------------------------------------------
# NETWORK SECURITY RULES
# --------------------------------------------------
# Allow ssh port access from Internet
resource "azurerm_network_security_rule" "validatorInboundInternetAllow" {
  name                        = "IInternetA"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["1122", "13000", "13002"]
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.validator.name
}

resource "azurerm_network_security_rule" "validatorInboundInternetUDPAllow" {
  name                        = "IInternetUDPA"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges      = ["12000", "12002"]
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.validator.name
}

# Allow ssh port access from Internet
resource "azurerm_network_security_rule" "sharedInboundInternetAllow" {
  name                        = "IInternetA"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["80", "1122", "9090", "9092"]
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.shared.name
}

# -----------------------------
# PUBLIC IPS
# -----------------------------
resource "azurerm_public_ip" "validator" {
  count               = var.nb_validators
  name                = format("ip-validator%03d", count.index + 1)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags                = local.eth_tags
}

resource "azurerm_public_ip" "shared" {
  name                = "ip-shared"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags                = local.eth_tags
}

# -----------------------------
# NETWORK INTERFACES
# -----------------------------
resource "azurerm_network_interface" "validator" {
  count                         = var.nb_validators
  name                          = format("nic-validator%03d", count.index + 1)
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_accelerated_networking = true
  internal_dns_name_label       = format("validator%03d", count.index + 1)
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.validator.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.validator.*.id, count.index)
  }

  tags = local.eth_tags
}

resource "azurerm_network_interface" "shared" {
  name                = "nic-shared"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # enable_accelerated_networking = true
  internal_dns_name_label = "shared"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.shared.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.shared.id
  }

  tags = local.eth_tags
}

# ---------------------------------------------------------
# MANAGED DISK
# ---------------------------------------------------------
resource "azurerm_managed_disk" "validator" {
  count                = var.nb_validators
  name                 = format("validator%03d-data", count.index + 1)
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 512

  lifecycle {
    prevent_destroy = true
  }

  tags = local.eth_tags
}

resource "azurerm_managed_disk" "shared" {
  name                 = "md-shared"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32

  lifecycle {
    prevent_destroy = true
  }

  tags = local.eth_tags
}

# -----------------------------
# VIRTUAL MACHINES
# -----------------------------
resource "azurerm_linux_virtual_machine" "validator" {
  count                 = var.nb_validators
  name                  = format("use2lvalidator%03dprod", count.index + 1)
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_E2s_v5"
  admin_username        = var.admin_username
  network_interface_ids = [local.nic_ids[count.index]]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = format("validator%03d-os", count.index + 1)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.default.rendered

  lifecycle {
    ignore_changes = [custom_data]
  }

  tags = local.eth_tags
}

resource "azurerm_linux_virtual_machine" "shared" {
  name                = "use3lsharedprod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.shared.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "shared-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.shared.rendered

  lifecycle {
    ignore_changes = [custom_data]
  }

  tags = local.eth_tags
}

# ------------------------------------
# VIRTUAL MACHINE DATA DISK ATTACHMENT
# ------------------------------------
resource "azurerm_virtual_machine_data_disk_attachment" "validator" {
  count              = var.nb_validators
  managed_disk_id    = azurerm_managed_disk.validator.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.validator.*.id[count.index]
  lun                = 1
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared" {
  managed_disk_id    = azurerm_managed_disk.shared.id
  virtual_machine_id = azurerm_linux_virtual_machine.shared.id
  lun                = 1
  caching            = "ReadWrite"
}

locals {
  nic_ids = azurerm_network_interface.validator.*.id
}
