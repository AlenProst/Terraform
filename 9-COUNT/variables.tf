variable rg_name {
  type        = string
  default     = "g1"
  description = "Location for the resources"
}

variable tf_location {
  type        = string
  default     = "westeurope"
  description = "Location for resources"
}

variable vn_name {
  type        = string
  default     = "first_tf_network"
  description = "Name of VN used"
}

variable subnet_name {
  type        = string
  default     = "first_tf_subnet"
  description = "Name for the subnet"
}

variable node_count {
  type        = number
  default     = 2
  description = "number of VMs"
}

variable "vm_count" {
  default = 3
}

