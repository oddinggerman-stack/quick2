output "vm_public_ips" {
  description = "Public IPs gameservers"
  value       = module.vm.vm_public_ips
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "matchmaking_fqdn" {
  value = module.aci.matchmaking_fqdn
}

output "dashboard_fqdn" {
  value = module.aci.dashboard_fqdn
}

output "telemetry_fqdn" {
  value = module.aci.telemetry_fqdn
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_file_share" {
  value = module.storage.file_share_name
}

output "vpn_public_ip" {
  value = module.vpn.vpn_public_ip
}

output "storage_alert_id" {
  value = module.monitoring.storage_alert_id
}