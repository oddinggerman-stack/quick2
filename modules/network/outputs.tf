output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_frontend_id" {
  value = azurerm_subnet.sb_frontend.id
}

output "subnet_gameserver_id" {
  value = azurerm_subnet.sb_gameserver.id
}

output "subnet_mgmt_id" {
  value = azurerm_subnet.sb_mgmt.id
}

output "subnet_telemetry_id" {
  value = azurerm_subnet.sb_telemetry.id
}