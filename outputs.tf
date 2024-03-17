output "primary_ipv4_address" {
  value = try(split("/", element(var.network_interfaces, 0).ip)[0], "")
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
