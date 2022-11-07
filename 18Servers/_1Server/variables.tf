variable "resource_prefix" {
  type        = string
  default     = ""
  description = "resource prefix for all resources in the RG"
}

variable "SRG_address_space" {
  default = ["10.1.0.0/16"]
}

variable "SRG_address_space_subnet" {
  default = "10.1.0.0/24"
}

variable "location" {
  type        = string
  default     = ""
  description = "location for the resources"
}

variable "vm1_size" {
  type        = string
  default     = ""
  description = "size for DC"
}

variable "sku" {
  type        = string
  default     = ""
  description = "OS for the DC"
}






