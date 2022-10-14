#Resource Groups
resource "azurerm_resource_group" "rg1" {
  name     = var.azure-rg-1
  location = var.loc1
}
#Resource Groups
resource "azurerm_resource_group" "rg2" {
  name     = var.azure-rg-2
  location = var.loc1
}
#VNETs and Subnets
#Hub VNET and Subnets
resource "azurerm_virtual_network" "region1-vnet1-hub1" {
  name                = var.region1-vnet1-name
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = [var.region1-vnet1-address-space]
  dns_servers         = ["10.10.1.4", "168.63.129.16", "8.8.8.8"]
}
resource "azurerm_subnet" "region1-vnet1-snet1" {
  name                 = var.region1-vnet1-snet1-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snet1-range]
}
resource "azurerm_subnet" "region1-vnet1-snet2" {
  name                 = var.region1-vnet1-snet2-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snet2-range]
}
resource "azurerm_subnet" "region1-vnet1-snet3" {
  name                 = var.region1-vnet1-snet3-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet1-hub1.name
  address_prefixes     = [var.region1-vnet1-snet3-range]
}
#Spoke VNET and Subnets 
resource "azurerm_virtual_network" "region1-vnet2-spoke1" {
  name                = var.region1-vnet2-name
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = [var.region1-vnet2-address-space]
  dns_servers         = ["10.10.1.4", "168.63.129.16", "8.8.8.8"]
}
resource "azurerm_subnet" "region1-vnet2-snet1" {
  name                 = var.region1-vnet2-snet1-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet2-spoke1.name
  address_prefixes     = [var.region1-vnet2-snet1-range]
}
resource "azurerm_subnet" "region1-vnet2-snet2" {
  name                 = var.region1-vnet2-snet2-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet2-spoke1.name
  address_prefixes     = [var.region1-vnet2-snet2-range]
}
resource "azurerm_subnet" "region1-vnet2-snet3" {
  name                 = var.region1-vnet2-snet3-name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.region1-vnet2-spoke1.name
  address_prefixes     = [var.region1-vnet2-snet3-range]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
#VNET Peering
resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "region1-vnet1-to-region1-vnet2"
  resource_group_name          = azurerm_resource_group.rg1.name
  virtual_network_name         = azurerm_virtual_network.region1-vnet1-hub1.name
  remote_virtual_network_id    = azurerm_virtual_network.region1-vnet2-spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "region1-vnet2-to-region1-vnet1"
  resource_group_name          = azurerm_resource_group.rg1.name
  virtual_network_name         = azurerm_virtual_network.region1-vnet2-spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.region1-vnet1-hub1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
#Lab NSG
resource "azurerm_network_security_group" "region1-nsg" {
  name                = "region1-nsg"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg2.name

  security_rule {
    name                       = "RDP-In"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#NSG Association to all Lab Subnets
resource "azurerm_subnet_network_security_group_association" "vnet1-snet1" {
  subnet_id                 = azurerm_subnet.region1-vnet1-snet1.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet2" {
  subnet_id                 = azurerm_subnet.region1-vnet1-snet2.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet1-snet3" {
  subnet_id                 = azurerm_subnet.region1-vnet1-snet3.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet2-snet1" {
  subnet_id                 = azurerm_subnet.region1-vnet2-snet1.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "vnet2-snet2" {
  subnet_id                 = azurerm_subnet.region1-vnet2-snet2.id
  network_security_group_id = azurerm_network_security_group.region1-nsg.id
}
#Create KeyVault ID
resource "random_id" "kvname" {
  byte_length = 5
  prefix      = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv1" {
  depends_on                  = [azurerm_resource_group.rg2]
  name                        = random_id.kvname.hex
  location                    = var.loc1
  resource_group_name         = var.azure-rg-2
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}
#Create KeyVault VM password
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}
#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on   = [azurerm_key_vault.kv1]
}
#Public IP
resource "azurerm_public_ip" "region1-dc01-pip" {
  name                = "region1-dc01-pip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
  allocation_method   = "Static"
  sku                 = "Standard"
}
#Create NIC and associate the Public IP
resource "azurerm_network_interface" "region1-dc01-nic" {
  name                = "region1-dc01-nic"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name


  ip_configuration {
    name                          = "region1-dc01-ipconfig"
    subnet_id                     = azurerm_subnet.region1-vnet1-snet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.region1-dc01-pip.id
  }
}
#Create data disk for NTDS storage
resource "azurerm_managed_disk" "region1-dc01-data" {
  name                 = "region1-dc01-data"
  location             = var.loc1
  resource_group_name  = azurerm_resource_group.rg1.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"
  max_shares           = "2"
}
#Create Domain Controller VM
resource "azurerm_windows_virtual_machine" "region1-dc01-vm" {
  name                = "region1-dc01-vm"
  depends_on          = [azurerm_key_vault.kv1]
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
  size                = var.vmsize-domaincontroller
  admin_username      = var.adminusername
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.region1-dc01-nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
#Attach Data Disk to Virtual Machine
resource "azurerm_virtual_machine_data_disk_attachment" "region1-dc01-data" {
  managed_disk_id    = azurerm_managed_disk.region1-dc01-data.id
  depends_on         = [azurerm_windows_virtual_machine.region1-dc01-vm]
  virtual_machine_id = azurerm_windows_virtual_machine.region1-dc01-vm.id
  lun                = "10"
  caching            = "None"
}
#Run setup script on dc01-vm
resource "azurerm_virtual_machine_extension" "region1-dc01-basesetup" {
  name                 = "region1-dc01-basesetup"
  virtual_machine_id   = azurerm_windows_virtual_machine.region1-dc01-vm.id
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.region1-dc01-data]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./baselab_DCSetup.ps1; exit 0;\""
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
        "fileUris": [
          "https://raw.githubusercontent.com/jakewalsh90/Terraform-Azure/main/PowerShell/baselab_DCSetup.ps1"
        ]
    }
  SETTINGS
}
# AVD Elements
# Resource Group
resource "azurerm_resource_group" "rg3" {
  name     = var.azure-rg-3
  location = var.loc1
}
# Host Pools
resource "azurerm_virtual_desktop_host_pool" "hp1" {
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg3.name

  name                     = "multi-user-pool"
  friendly_name            = "multi-user-pool"
  validate_environment     = false
  start_vm_on_connect      = false
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "1 to many Host Pool"
  type                     = "Pooled"
  maximum_sessions_allowed = 50
  load_balancer_type       = "DepthFirst"
}
resource "azurerm_virtual_desktop_host_pool" "hp2" {
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg3.name

  name                             = "single-user-pool"
  friendly_name                    = "single-user-pool"
  validate_environment             = false
  start_vm_on_connect              = false
  custom_rdp_properties            = "audiocapturemode:i:1;audiomode:i:0;"
  description                      = "1 to 1 Host Pool"
  type                             = "Personal"
  maximum_sessions_allowed         = 999999
  load_balancer_type               = "Persistent"
  personal_desktop_assignment_type = "Automatic"
}
# App Groups
resource "azurerm_virtual_desktop_application_group" "appgroup1" {
  name                = "app-group1-multi"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg3.name

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hp1.id
  friendly_name = "Multi User Desktop"
  description   = "Multi User Desktop Session"
}
resource "azurerm_virtual_desktop_application_group" "appgroup2" {
  name                = "app-group2-single"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg3.name

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hp2.id
  friendly_name = "Single User Desktop"
  description   = "Single User Desktop Session"
}
# Workspaces 
resource "azurerm_virtual_desktop_workspace" "demo-avd-workspace" {
  name                = "demolab-workspace"
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg3.name

  friendly_name = "demo-avd-workspace"
  description   = "Demo AVD Workspace"
}
# App Group to Workspace Assignment
resource "azurerm_virtual_desktop_workspace_application_group_association" "multi-user" {
  workspace_id         = azurerm_virtual_desktop_workspace.demo-avd-workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.appgroup1.id
}
resource "azurerm_virtual_desktop_workspace_application_group_association" "single-user" {
  workspace_id         = azurerm_virtual_desktop_workspace.demo-avd-workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.appgroup2.id
}
# Azure NetApp Files
resource "azurerm_netapp_account" "region1-anf" {
  name                = "anf-account"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.loc1
}
resource "azurerm_netapp_pool" "region1-anf-pool1" {
  name                = "pool1"
  account_name        = azurerm_netapp_account.region1-anf.name
  location            = var.loc1
  resource_group_name = azurerm_resource_group.rg1.name
  service_level       = "Standard"
  size_in_tb          = 4
}
