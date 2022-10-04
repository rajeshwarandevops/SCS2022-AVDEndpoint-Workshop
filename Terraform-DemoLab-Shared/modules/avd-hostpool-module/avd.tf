# Resource Group
resource "azurerm_resource_group" "rg" {
  for_each = var.labs
  name     = "rg-avd-lab-${each.value.name}"
  location = var.location
}
# VNET
resource "azurerm_virtual_network" "vn" {
  for_each            = var.labs
  name                = "vnet-avd-lab-${each.value.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  address_space       = [each.value.vnet_cidr]
  dns_servers         = [var.dns]
}
# Subnet
resource "azurerm_subnet" "region1-vnet1-snet1" {
  for_each             = var.labs
  name                 = "vnet-avd-lab-${each.value.name}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vn[each.key].name
  address_prefixes     = [each.value.subnet_cidr]
}
# VNET peering
resource "azurerm_virtual_network_peering" "lab-to-hub" {
  for_each                  = var.labs
  name                      = "${each.value.name}-to-hub"
  resource_group_name       = azurerm_resource_group.rg[each.key].name
  virtual_network_name      = azurerm_virtual_network.vn[each.key].name
  remote_virtual_network_id = var.hub_vnetid
}

resource "azurerm_virtual_network_peering" "hub-to-lab" {
  for_each                  = var.labs
  name                      = "hub-to-${each.value.name}"
  resource_group_name       = var.hub_rg
  virtual_network_name      = var.hub_vnetname
  remote_virtual_network_id = azurerm_virtual_network.vn[each.key].id
}
# Host Pool
resource "azurerm_virtual_desktop_host_pool" "hp" {
  for_each            = var.labs
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  name                     = "hp-avd-lab-${each.value.name}"
  friendly_name            = "hp-avd-lab-${each.value.name}"
  validate_environment     = false
  start_vm_on_connect      = false
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "1 to many Host Pool"
  type                     = "Pooled"
  maximum_sessions_allowed = 50
  load_balancer_type       = "DepthFirst"
}
# App Groups
resource "azurerm_virtual_desktop_application_group" "ag" {
  for_each                     = var.labs
  name                         = "ag-avd-lab-${each.value.name}"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg[each.key].name
  type                         = "Desktop"
  host_pool_id                 = azurerm_virtual_desktop_host_pool.hp[each.key].id
  friendly_name                = "ag-avd-lab-${each.value.name}"
  description                  = "Multi User Desktop Session"
  default_desktop_display_name = "${each.value.name} - SCS Lab Test Desktop"
}
# Workspaces 
resource "azurerm_virtual_desktop_workspace" "ws" {
  for_each            = var.labs
  name                = "ws-avd-lab-${each.value.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  friendly_name = "ws-avd-lab-${each.value.name}"
  description   = "Demo AVD Workspace"
}
# App Group to Workspace Assignment
resource "azurerm_virtual_desktop_workspace_application_group_association" "assignment" {
  for_each             = var.labs
  workspace_id         = azurerm_virtual_desktop_workspace.ws[each.key].id
  application_group_id = azurerm_virtual_desktop_application_group.ag[each.key].id
}