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

data "template_file" "cloudinit" {
  template = <<-EOT
  #cloud-config

  hostname: ${var.hostname}
  fqdn: ${var.hostname}.${var.domain}

  ssh_pwauth: True
  ssh_deletekeys: False

  %{ if length(var.ssh_keys) > 0 }
  ssh_authorized_keys:
  %{ for key in var.ssh_keys }
    - "${key}"
  %{ endfor }
  %{ endif }

  network:
    ethernets:
      eth0:
        dhcp4: ${var.dhcp}
        dhcp6: false
        %{ if var.dhcp == false ~}
        addresses: ["${var.ip}"]
        gateway4: ${var.gateway}
        nameservers:
        %{ if length(var.nameservers) > 0 ~}
        %{ for nameserver in var.nameservers ~}
          - ${nameserver}
        %{ endfor ~}
        %{ endif ~}
        %{ endif }

  EOT
}

resource "libvirt_cloudinit_disk" "init_disk" {
  name = "${var.hostname}_cloudinit"
  pool = var.libvirt_pool

  user_data = data.template_file.cloudinit.rendered
}

resource "libvirt_domain" "domain" {
  name   = var.hostname
  memory = var.memory
  vcpu   = var.vcpu

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

  network_interface {
    macvtap        = var.libvirt_external_interface
    hostname       = var.hostname
    wait_for_lease = false
    mac            = var.mac // For some providers, this is required
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
  groups = concat(var.ansible_groups, [var.domain])

  variables = {
    ansible_host = coalesce(var.ansible_host, "${var.ip}", "${var.hostname}.${var.domain}")
    ansible_user = var.ansible_user
  }
}
