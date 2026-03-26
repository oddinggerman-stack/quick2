variable "prefix" {
  description = "Naamprefix voor alle resources"
  type        = string
  default     = "DP5"
}

variable "location" {
  description = "Azure regio"
  type        = string
  default     = "westeurope"
}

variable "ssh_public_key_path" {
  description = "Pad naar je publieke SSH-key"
  type        = string
  default     = "~/.ssh/id_azure.pub"
}