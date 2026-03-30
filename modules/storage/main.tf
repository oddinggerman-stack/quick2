resource "azurerm_storage_account" "main" {
  name                     = lower("${var.prefix}storageprod")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "gamelogs" {
  name                  = "gamelogs"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "snapshots" {
  name                  = "world-snapshots"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_share" "configs" {
  name               = "gameconfigs"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 10
}