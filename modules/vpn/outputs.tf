output "vpn_public_ip" {
  value = azurerm_public_ip.vpn_pip.ip_address
}