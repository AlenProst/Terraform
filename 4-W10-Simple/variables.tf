variable rg_name {
  type        = string
  default     = "g1"
  description = "Location for the resources"
}

variable tf_location {
  type        = string
  default     = "eastus"
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


