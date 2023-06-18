resource "libvirt_volume" "cloudinit_image" {
  name   = "${var.hostname}_cloudinit_image"
  pool   = var.libvirt_pool
  source = var.cloudinit_image
  format = "qcow2"
}

resource "libvirt_volume" "disk" {
  name           = "${var.hostname}_disk"
  pool           = var.libvirt_pool
  base_volume_id = libvirt_volume.cloudinit_image.id
  size           = var.disk_size
}

data "template_file" "cloudinit_user_data" {
  template = <<-EOT
#cloud-config

hostname: ${var.hostname}
fqdn: ${var.hostname}.${var.domain}

ssh_pwauth: True
ssh_deletekeys: False

%{if length(var.ssh_keys) > 0}
ssh_authorized_keys:
%{for key in var.ssh_keys}
  - "${key}"
%{endfor}
%{endif}

EOT
}

data "template_file" "cloudinit_network_data" {
  template = <<-EOT
version: 2
ethernets:
%{for interface in var.network_interfaces ~}
  ${interface.name~}:
%{if interface.dhcp == null~}
    dhcp4: true
%{endif~}
%{if interface.dhcp != null~}
    dhcp4: ${interface.dhcp}
%{endif~}
%{if interface.dhcp != true~}
%{if interface.ip != null~}
    addresses: ["${interface.ip}"]
%{endif~}
%{if interface.gateway != null~}
    gateway4: ${interface.gateway}
%{endif~}
%{if interface.nameservers != null~}
%{if length(interface.nameservers) > 0~}
    nameservers:
%{for nameserver in interface.nameservers~}
      - ${nameserver}
%{endfor~}
%{endif~}
%{endif~}
%{if interface.additional_routes != null~}
%{if length(interface.additional_routes) > 0~}
    routes:
%{for route in interface.additional_routes~}
      - to: ${route.network}
        via: ${route.gateway}
%{endfor~}
%{endif~}
%{endif~}
%{endif~}
%{endfor~}

EOT
}

resource "libvirt_cloudinit_disk" "init_disk" {
  name = "${var.hostname}_cloudinit"
  pool = var.libvirt_pool

  user_data = data.template_file.cloudinit_user_data.rendered
  network_config = data.template_file.cloudinit_network_data.rendered
}

resource "libvirt_domain" "domain" {
  name   = var.hostname
  memory = var.memory
  vcpu   = var.vcpu

  cpu {
    mode = "host-passthrough"
  }

  autostart = var.autostart

  cloudinit = libvirt_cloudinit_disk.init_disk.id // Attach cloud-init disk

  disk {
    volume_id = libvirt_volume.disk.id
  }

  dynamic "disk" {
    for_each = var.disk_passthroughs
    content {
      block_device = disk.value
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces

    content {
      macvtap        = network_interface.value.macvtap
      network_name   = network_interface.value.network_name
      network_id     = network_interface.value.network_id
      hostname       = network_interface.value.hostname
      wait_for_lease = network_interface.value.wait_for_lease
      mac            = network_interface.value.mac // For some providers, this is required
    }
  }

  xml {
    xslt = file("${path.module}/nicmodel.xsl")
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = var.spice_server_enabled ? "address" : "none"
  }

}

resource "ansible_host" "default" {
  name   = coalesce(var.ansible_name, var.hostname)
  groups = concat(var.ansible_groups, [lower(replace(var.domain, ".", "_"))])

  variables = {
    ansible_host = coalesce(var.ansible_host, var.network_interfaces[0].ip, var.domain != "" ? "${var.hostname}.${var.domain}" : var.hostname)
    ansible_user = var.ansible_user
  }
}
