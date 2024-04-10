output "primary_ipv4_address" {
  value = try(split("/", element(var.network_interfaces, 0).ip)[0], "")
}

output "name" {
  value = var.name
}

output "domain" {
  value = var.domain
}

output "id" {
  value = var.name
}
