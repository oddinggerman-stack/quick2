output "vm_public_ips" {
  description = "Public ip's gameservers. gesorteerd op zone"
  value       = { for k, pip in azurerm_public_ip.vm_pip : k => pip.ip_address }
}

output "vm_names" {
  value = { for k, vm in azurerm_linux_virtual_machine.gameserver : k => vm.name }
}

output "vm_ids" {
  description = "Resource IDs van alle gameserver VMs"
  value       = [for vm in azurerm_linux_virtual_machine.gameserver : vm.id]
}