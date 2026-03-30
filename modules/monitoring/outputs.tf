output "cpu_alert_ids" {
  value = { for k, v in azurerm_monitor_metric_alert.cpu_high : k => v.id }
}

output "storage_alert_id" {
  value = azurerm_monitor_metric_alert.storage_capacity.id
}