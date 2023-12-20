# -----------------------------
# SUBNETS
# -----------------------------
resource "azurerm_subnet" "theta" {
  name                 = "theta-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.4.0/24"]
}

# -----------------------------
# NETWORK SECURITY GROUPS
# -----------------------------

resource "azurerm_network_security_group" "theta" {
  name                = "nsg-theta"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.theta_tags
}

resource "azurerm_subnet_network_security_group_association" "theta" {
  subnet_id                 = azurerm_subnet.theta.id
  network_security_group_id = azurerm_network_security_group.theta.id
}

# --------------------------------------------------
# NETWORK SECURITY RULES
# --------------------------------------------------

# Allow port 3389 access from Internet
resource "azurerm_network_security_rule" "thetaInboundInternetAllow" {
  name                        = "IInternetA"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["1122", "3389"]
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.theta.name
}

# -----------------------------
# PUBLIC IPS
# -----------------------------
resource "azurerm_public_ip" "theta-edge" {
  count               = var.nb_edge_nodes
  name                = format("ip-theta-edge%03d", count.index + 1)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags                = local.theta_tags
}

resource "azurerm_public_ip" "theta-guardian" {
  name                = "ip-theta-guardian"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags                = local.theta_tags
}

# -----------------------------
# NETWORK INTERFACES
# -----------------------------
resource "azurerm_network_interface" "theta-edge" {
  count                         = var.nb_edge_nodes
  name                          = format("nic-theta-edge%03d", count.index + 1)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  #  enable_accelerated_networking = true
  internal_dns_name_label       = format("theta-edge%03d", count.index + 1)
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.theta.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.theta-edge.*.id, count.index)
  }

  tags = local.theta_tags
}

resource "azurerm_network_interface" "theta-guardian" {
  name                          = "nic-theta-guardian"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  # enable_accelerated_networking = true
  internal_dns_name_label       = "theta-guardian"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.theta.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.theta-guardian.id
  }

  tags = local.theta_tags
} 

# ---------------------------------------------------------
# MANAGED DISK
# ---------------------------------------------------------
resource "azurerm_managed_disk" "theta-guardian" {
  name                 = "md-theta-guardian"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 64

  lifecycle {
    prevent_destroy = true
  }

  tags = local.theta_tags
}

# -----------------------------
# VIRTUAL MACHINES
# -----------------------------
resource "azurerm_windows_virtual_machine" "theta-edge" {
  count                 = var.nb_edge_nodes
  name                  = format("thetaedge%03d", count.index + 1)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.windows_admin_password
  network_interface_ids = [local.nic_thetaedge_ids[count.index]]

  os_disk {
    name                 = format("thetaedge%03d-os", count.index + 1)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [resource_group_name, admin_username, admin_password]
  }

  tags = local.theta_tags
}

resource "azurerm_linux_virtual_machine" "theta-guardian" {
  name                = "theta-grdn"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2ms"
  admin_username        = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.theta-guardian.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "theta-guardian-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.theta.rendered

  lifecycle {
    ignore_changes = [custom_data]
  }

  tags = local.theta_tags
}

# ------------------------------------
# VIRTUAL MACHINE DATA DISK ATTACHMENT
# ------------------------------------
resource "azurerm_virtual_machine_data_disk_attachment" "theta-guardian-dda" {
  managed_disk_id    = azurerm_managed_disk.theta-guardian.id
  virtual_machine_id = azurerm_linux_virtual_machine.theta-guardian.id
  lun                = 1
  caching            = "ReadWrite"
}

locals {
  nic_thetaedge_ids = azurerm_network_interface.theta-edge.*.id
}