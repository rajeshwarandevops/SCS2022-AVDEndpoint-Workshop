# Resource Group
resource "azurerm_resource_group" "rg" {
  for_each = var.pools
  name     = "rg-avd-lab-${each.value.name}"
  location = var.loc1
}
# VNET
resource "azurerm_virtual_network" "vn" {
  for_each            = var.pools
  name                = "vnet-avd-lab-${each.value.name}"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg[each.key].name
  address_space       = each.value.vnet_cidr
  dns_servers         = ["10.10.1.4", "168.63.129.16", "8.8.8.8"]
}
# Subnet
resource "azurerm_subnet" "region1-vnet1-snet1" {
  for_each             = var.pools
  name                 = "vnet-avd-lab-${each.value.name}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vn[each.key].name
  address_prefixes     = each.value.subnet_cidr
}
# Host Pool
resource "azurerm_virtual_desktop_host_pool" "hp" {
  for_each            = var.pools
  location            = var.loc1
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
  for_each            = var.pools
  name                = "ag-avd-lab-${each.value.name}"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg[each.key].name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.hp[each.key].id
  friendly_name       = "ag-avd-lab-${each.value.name}"
  description         = "Multi User Desktop Session"
}
# Workspaces 
resource "azurerm_virtual_desktop_workspace" "ws" {
  for_each            = var.pools
  name                = "ws-avd-lab-${each.value.name}"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg[each.key].name

  friendly_name = "ws-avd-lab-${each.value.name}"
  description   = "Demo AVD Workspace"
}
# App Group to Workspace Assignment
resource "azurerm_virtual_desktop_workspace_application_group_association" "assignment" {
  for_each             = var.pools
  workspace_id         = azurerm_virtual_desktop_workspace.ws[each.key].id
  application_group_id = azurerm_virtual_desktop_application_group.eg[each.key].id
}