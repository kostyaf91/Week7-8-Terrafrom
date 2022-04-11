# Resource group creation
resource "azurerm_resource_group" "Main" {
  name     = var.rg_name
  location = var.location
}
# Virtual network creation
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.Main.location
  resource_group_name = azurerm_resource_group.Main.name
  address_space       = ["10.0.0.0/16"]
}
# Subnets creation
resource "azurerm_subnet" "public_subnet" {
  name                 = var.public_subnet_name
  resource_group_name  = azurerm_resource_group.Main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]

}
resource "azurerm_subnet" "private_subnet" {
  name                                           = var.private_subnet_name
  resource_group_name                            = azurerm_resource_group.Main.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.1.0/24"]
  #enforce_private_link_endpoint_network_policies = true

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}
# NSG creation
resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.Main.location
  name                = var.nsg_name
  resource_group_name = azurerm_resource_group.Main.name

  security_rule {
    access    = "Allow"
    direction = "Inbound"
    name      = "ssh_to_public"
    priority  = 100
    protocol  = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "5.29.11.234"
    destination_address_prefix = "10.0.0.0/24"
  }
  security_rule {
    access    = "Allow"
    direction = "Inbound"
    name      = "8080_to_public"
    priority  = 110
    protocol  = "*"
    source_port_range = "*"
    destination_port_range = "8080"
    source_address_prefix = "*"
    destination_address_prefix = "10.0.0.0/24"
  }
  security_rule {
    access    = "Allow"
    direction = "Inbound"
    name      = "ssh_for_master"
    priority  = 120
    protocol  = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "10.0.0.0/24"
    destination_address_prefix = "10.0.0.0/24"
  }
  security_rule {
    access    = "Allow"
    direction = "Inbound"
    name      = "5432_public_to_private"
    priority  = 130
    protocol  = "Tcp"
    source_port_range = "*"
    destination_port_range = "5432"
    source_address_prefix = "10.0.0.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }
}

#NSG association
resource "azurerm_subnet_network_security_group_association" "nsg-to-public" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.public_subnet.id
}
resource "azurerm_subnet_network_security_group_association" "nsg-to-private" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private_subnet.id
}



