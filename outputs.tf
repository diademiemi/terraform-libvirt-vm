output "primary_ipv4_address" {
  value = try(var.network_interfaces[0].ip, "")
}

output "server_name" {
  value = var.hostname
}

output "server_domain" {
  value = var.domain
}

output "server_id" {
  value = var.hostname
}
