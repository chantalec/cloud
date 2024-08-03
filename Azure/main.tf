# Generates a random pet name that's intended to be used a unique identifiers
resource "random_pet" "rg_name" {
  # A string to prefix the name with
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "my-rg" {
  # The Azure region where the Resource Group should exist
  location = var.resource_group_location
  # Name to be used for this Resource Group
  name = random_pet.rg_name.id
}

# Virtual network
resource "azurerm_virtual_network" "my-vn" {
  name                = "my-vn"
  resource_group_name = azurerm_resource_group.my-rg.name
  location            = azurerm_resource_group.my-rg.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "my-subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.my-rg.name
  virtual_network_name = azurerm_virtual_network.my-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "my-sg" {
  name                = "my-sg"
  location            = azurerm_resource_group.my-rg.location
  resource_group_name = azurerm_resource_group.my-rg.name
}

# Network Security Group Rule
resource "azurerm_network_security_rule" "my-sgrule" {
  name                        = "my-sgrule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my-rg.name
  network_security_group_name = azurerm_network_security_group.my-sg.name
}

# Security Group Associations
resource "azurerm_subnet_network_security_group_association" "my-sga" {
  subnet_id                 = azurerm_subnet.my-subnet.id
  network_security_group_id = azurerm_network_security_group.my-sg.id
}

# Public IP
resource "azurerm_public_ip" "my-public-ip" {
  name                = "my-public-ip"
  resource_group_name = azurerm_resource_group.my-rg.name
  location            = azurerm_resource_group.my-rg.location
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "my-nic" {
  name                = "my-nic"
  location            = azurerm_resource_group.my-rg.location
  resource_group_name = azurerm_resource_group.my-rg.name

  ip_configuration {
    name                          = "my-nic-config"
    subnet_id                     = azurerm_subnet.my-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my-public-ip.id
  }
}

# Random Number
resource "random_id" "random_id" {
  keepers = {
    # Generates a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.my-rg.name
  }

  byte_length = 8
}

# Azure Storage Account
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.my-rg.location
  resource_group_name      = azurerm_resource_group.my-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "my-vm" {
  name                  = "my-vm"
  resource_group_name   = azurerm_resource_group.my-rg.name
  location              = azurerm_resource_group.my-rg.location
  size                  = "Standard_B1s"
  admin_username        = var.username
  network_interface_ids = [azurerm_network_interface.my-nic.id]
  computer_name         = "hostname"

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  os_disk {
    name                 = "my_os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}