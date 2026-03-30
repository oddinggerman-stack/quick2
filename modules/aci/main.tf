resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

#matchmaking api
resource "azurerm_container_group" "matchmaking" {
  name                = "${var.prefix}-aci-matchmaking"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "${lower(var.prefix)}-matchmaking-${random_integer.suffix.result}"
  restart_policy = "Always"

  image_registry_credential {
    server   = var.acr_login_server
    username = var.acr_username
    password = var.acr_password
  }

  container {
    name   = "matchmaking"
    image  = "${var.acr_login_server}/matchmaking:latest"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

#player dashboard
resource "azurerm_container_group" "dashboard" {
  name                = "${var.prefix}-aci-dashboard"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "${lower(var.prefix)}-dashboard-${random_integer.suffix.result}"
  restart_policy = "Always"

  image_registry_credential {
    server   = var.acr_login_server
    username = var.acr_username
    password = var.acr_password
  }

  container {
    name   = "dashboard"
    image  = "${var.acr_login_server}/player-dashboard:latest"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

#telemetry collector
resource "azurerm_container_group" "telemetry" {
  name                = "${var.prefix}-aci-telemetry"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "${lower(var.prefix)}-telemetry-${random_integer.suffix.result}"
  restart_policy = "Always"

  image_registry_credential {
    server   = var.acr_login_server
    username = var.acr_username
    password = var.acr_password
  }

  container {
    name   = "telemetry"
    image  = "${var.acr_login_server}/telemetry-collector:latest"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}