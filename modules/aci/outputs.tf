output "matchmaking_fqdn" {
  value = azurerm_container_group.matchmaking.fqdn
}

output "dashboard_fqdn" {
  value = azurerm_container_group.dashboard.fqdn
}

output "telemetry_fqdn" {
  value = azurerm_container_group.telemetry.fqdn
}