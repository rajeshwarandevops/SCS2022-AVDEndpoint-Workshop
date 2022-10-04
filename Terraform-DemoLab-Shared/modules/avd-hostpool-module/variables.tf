variable "location" {
  description = "default location to use"
  default     = "uk south"
}
variable "dns" {
  description = "dns servers for the lab vnet"
  default     = "10.10.10.1"
}
variable "hub_vnetid" {
  description = "hub vnet id to peer into"
  default     = "vnetid"
}
variable "hub_vnetname" {
  description = "hub vnet name to peer into"
  default     = "vnetid"
}
variable "hub_rg" {
  description = "hub vnet name to peer into"
  default     = "vnetid"
}
variable "labs" {
  description = "dns servers for the lab vnet"
  type        = map(any)
  default = {
    lab1 = {
      name        = "lab1"
      vnet_cidr   = "10.11.0.0/16"
      subnet_cidr = "10.11.1.0/24"
    }
  }
}