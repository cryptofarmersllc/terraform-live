# -----------------------------
# SUBNETS
# -----------------------------
resource "azurerm_subnet" "executor" {
  name                 = "executor-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

# -----------------------------
# NETWORK SECURITY GROUPS
# -----------------------------
resource "azurerm_network_security_group" "executor" {
  name                = "nsg-executor"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.eth_tags
}

resource "azurerm_subnet_network_security_group_association" "executor" {
  subnet_id                 = azurerm_subnet.executor.id
  network_security_group_id = azurerm_network_security_group.executor.id
}

# --------------------------------------------------
# NETWORK SECURITY RULES
# --------------------------------------------------
# Allow ssh port access from Internet
resource "azurerm_network_security_rule" "executorInboundInternetAllow" {
  name                        = "IInternetA"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["1122", "13000", "30303"]
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.executor.name
}

resource "azurerm_network_security_rule" "executorInboundInternetUDPAllow" {
  name                        = "IInternetUDPA"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges      = ["12000", "30303"]
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.executor.name
}

# -----------------------------
# PUBLIC IPS
# -----------------------------
resource "azurerm_public_ip" "executor" {
  count               = var.nb_executors
  name                = format("ip-executor%03d", count.index + 1)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags                = local.eth_tags
}

# -----------------------------
# NETWORK INTERFACES
# -----------------------------
resource "azurerm_network_interface" "executor" {
  count                         = var.nb_executors
  name                          = format("nic-executor%03d", count.index + 1)
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_accelerated_networking = true
  internal_dns_name_label       = format("executor%03d", count.index + 1)
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.executor.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.executor.*.id, count.index)
  }

  tags = local.eth_tags
}

# ---------------------------------------------------------
# MANAGED DISK
# ---------------------------------------------------------
resource "azurerm_managed_disk" "executor" {
  count                = var.nb_executors
  name                 = format("executor%03d-data", count.index + 1)
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 2048

  /* lifecycle {
    prevent_destroy = true
  } */

  tags = local.eth_tags
}

# -----------------------------
# VIRTUAL MACHINES
# -----------------------------
resource "azurerm_linux_virtual_machine" "executor" {
  count                 = var.nb_executors
  name                  = format("use2lexecutor%03dprod", count.index + 1)
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_E4s_v5"
  admin_username        = var.admin_username
  network_interface_ids = [local.nic_executor_ids[count.index]]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = format("executor%03d-os", count.index + 1)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.default.rendered

  lifecycle {
    ignore_changes = [custom_data]
  }

  tags = local.eth_tags
}

# ------------------------------------
# VIRTUAL MACHINE DATA DISK ATTACHMENT
# ------------------------------------
resource "azurerm_virtual_machine_data_disk_attachment" "executor" {
  count              = var.nb_executors
  managed_disk_id    = azurerm_managed_disk.executor.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.executor.*.id[count.index]
  lun                = 1
  caching            = "ReadWrite"
}

locals {
  nic_executor_ids = azurerm_network_interface.executor.*.id
}
