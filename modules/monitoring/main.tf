#Alert cpu hit 80 %
resource "azurerm_monitor_metric_alert" "cpu_high" {
  for_each            = { for idx, id in var.vm_ids : "vm-${idx}" => id }
  name                = "${var.prefix}-alert-cpu-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Alert als CPU gebruik boven 80% komt op gameserver"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

#Alert storage hit 80 %
resource "azurerm_monitor_metric_alert" "storage_capacity" {
  name                = "${var.prefix}-alert-storage-capacity"
  resource_group_name = var.resource_group_name
  scopes              = [var.storage_account_id]
  description         = "Alert als storage capaciteit boven 80% van 1TB komt"
  severity            = 2
  frequency           = "PT1H"
  window_size         = "PT6H"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 858993459200
  }
}