## Module Resources
module "avd-hostpool-module" {
  source = "./modules/avd-hostpool-module"
  # Global Variables 
  location = var.loc1
  # Host Pools
  pools = {
    pool1 = {
      name        = "attendee1"
      vnet_cidr   = "10.11.0.0/16"
      subnet_cidr = "10.11.1.0/24"
    }
  }
}