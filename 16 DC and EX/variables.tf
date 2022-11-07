variable "resource_group" {
  type        = string
  default     = ""
  description = "resource group for the resources"
}

variable "location" {
  type        = string
  default     = ""
  description = "location for the resources"
}

variable "vn_name" {
  type        = string
  default     = ""
  description = "virtual network for the resources"
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "subnet for the resources"
}

variable "public_ip_1" {
  type        = string
  default     = ""
  description = "public ip for the DC"
}

variable "nic_name_1" {
  type        = string
  default     = ""
  description = "nic for DC"
}

variable "nsg_name" {
  type        = string
  default     = ""
  description = "nsg for the machines"
}

variable "rule_nsg_name" {
  type        = string
  default     = ""
  description = "description"
}

variable "DC_name" {
  type        = string
  default     = ""
  description = "name for the DC"
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

variable "extention_name" {
  type        = string
  default     = ""
  description = "name for the DC extention"
}

#####

variable "public_ip_2" {
  type        = string
  default     = ""
  description = "name for ip for EX"
}

variable "nic_name_2" {
  type        = string
  default     = ""
  description = "name for nic for EX"
}

variable "exchange_name" {
  type        = string
  default     = ""
  description = "name for exchange server"
}

variable "exchange_size" {
  type        = string
  default     = ""
  description = "size of the machine for exchange"
}

variable "sku_ex" {
  type        = string
  default     = ""
  description = "OS for the exchange"
}

variable "admin_password" {
  type        = string
  default     = ""
  description = "password for the joinn"
}













