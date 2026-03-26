resource "random_integer" "aci_suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_container_group" "matchmaking_api" {
  name                = "${var.prefix}-matchmaking-api"
  location            = "$var.location"
  resource_group_name = "&var.resourcegroup"

  os_type         = "Linux"
  ip_address_type = "Public"

  dns_name_label = "${var.prefix}-match-aci-${random_integer.aci_suffix.result}"

  image_registry_credential {
    server      = ""
  }

  container {
    name   = "web"
    image  = "nginx:latest"
    cpu    = 0.5
    memory = 0.5

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "NGINX_HOST" = "localhost"
    }
  }
}

output "aci_fqdn" {
  description = "Publieke DNS naam van de ACI container"
  value       = azurerm_container_group.aci_web.fqdn
}
