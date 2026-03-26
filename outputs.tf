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