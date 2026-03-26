resource "azurerm_container_registry" "acr" {
  name                = lower("${var.prefix}acrpowerplay")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "null_resource" "build_and_push" {
  depends_on = [azurerm_container_registry.acr]

  triggers = {
    matchmaking_dockerfile = filemd5("${path.root}/c2-dp5-applicaties/matchmaking-api/Dockerfile")
    dashboard_dockerfile   = filemd5("${path.root}/c2-dp5-applicaties/player-dashboard/Dockerfile")
    telemetry_dockerfile   = filemd5("${path.root}/c2-dp5-applicaties/telemetry-collector/Dockerfile")
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      az acr build --registry ${azurerm_container_registry.acr.name} --image matchmaking:latest --file ${path.root}/c2-dp5-applicaties/matchmaking-api/Dockerfile ${path.root}/c2-dp5-applicaties/matchmaking-api/ && \
      az acr build --registry ${azurerm_container_registry.acr.name} --image player-dashboard:latest --file ${path.root}/c2-dp5-applicaties/player-dashboard/Dockerfile ${path.root}/c2-dp5-applicaties/player-dashboard/ && \
      az acr build --registry ${azurerm_container_registry.acr.name} --image telemetry-collector:latest --file ${path.root}/c2-dp5-applicaties/telemetry-collector/Dockerfile ${path.root}/c2-dp5-applicaties/telemetry-collector/
    EOT
  }
}