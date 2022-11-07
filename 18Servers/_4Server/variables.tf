
variable "prefix" {
  type        = string
  default     = ""
  description = "resource prefix for all resources in the RG"
}

variable "romote_SRG_VN_id" {
  type        = string
  default     = ""
  description = "resource prefix for all resources in the RG"
}

variable "resource_group_remote" {
  type        = string
  default     = ""
  description = "resource prefix for all resources in the RG"
}

variable "remote_SRG_VN_name" {
  type        = string
  default     = ""
  description = "resource prefix for all resources in the RG"
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

variable "SRG-2_address_space" {
  default = ["10.1.0.0/16"]
}

variable "SRG-2_address_space_subnet" {
  default = "10.1.0.0/24"
}






