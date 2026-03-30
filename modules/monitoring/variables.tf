variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_ids" {
  description = "Resource IDs van de gameserver VMs"
  type        = list(string)
}

variable "storage_account_id" {
  description = "Resource ID van het storage account voor diagnostics"
  type        = string
}