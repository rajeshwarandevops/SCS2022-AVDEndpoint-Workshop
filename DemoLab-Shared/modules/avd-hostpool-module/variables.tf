variable "name" {
  description = "the name to be used for the host pool and other resources"
  default     = "test1"
}
variable "vnet_cidr" {
  description = "CIDR Range for VNETs"
  default     = "10.20.0.0/16"
}
variable "subnet_cidr" {
  description = "CIDR Range for Subnets"
  default     = "10.20.1.0/24"
}