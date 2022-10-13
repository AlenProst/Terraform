variable base_name {
  type        = string
  default     = ""
  description = "name for the storage account"
}

variable rg_name {
  type        = string
  default     = ""
  description = "name of the resource group"
}

variable location {
  type        = string
  default     = ""
  description = "location for deployment of SA"
}
