variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "zones" {
  description = "Availability zones voor de gameservers"
  type        = list(string)
  default     = ["1", "2"]
}