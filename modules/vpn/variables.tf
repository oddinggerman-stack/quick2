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

variable "skylab_public_ip" {
  type    = string
  default = "145.44.233.88"
}

variable "ipsec_psk" {
  type      = string
  sensitive = true
  default   = "Powerplay2026StrongKey!"
}