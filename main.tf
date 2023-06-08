resource "libvirt_volume" "cloudinit_image" {
  name   = "${var.vm_hostname}_cloudinit_image"
  pool   = var.vm_libvirt_pool
  source = var.vm_cloudinit_image
  format = "qcow2"
}

resource "libvirt_volume" "vm_disk" {
  name           = "${var.vm_hostname}_vm_disk"
  pool           = var.vm_libvirt_pool
  base_volume_id = libvirt_volume.cloudinit_image.id
  size           = var.vm_disk_size
}

data "template_file" "vm_cloudinit" {
  template = <<-EOT
  #cloud-config

  hostname: ${var.vm_hostname}
  fqdn: ${var.vm_hostname}.${var.vm_domain}

  ssh_pwauth: True
  ssh_deletekeys: False

  %{ if length(var.vm_ssh_keys) > 0 }
  ssh_authorized_keys:
  %{ for key in var.vm_ssh_keys }
    - "${key}"
  %{ endfor }
  %{ endif }

  network:
    ethernets:
      eth0:
        dhcp4: ${var.vm_dhcp}
        dhcp6: false
        %{ if var.vm_dhcp == false ~}
        addresses: ["${var.vm_ip}"]
        gateway4: ${var.vm_gateway}
        nameservers:
        %{ if length(var.vm_nameservers) > 0 ~}
        %{ for nameserver in var.vm_nameservers ~}
          - ${nameserver}
        %{ endfor ~}
        %{ endif ~}
        %{ endif }

  EOT
}

resource "libvirt_cloudinit_disk" "init_disk" {
  name = "${var.vm_hostname}_cloudinit"
  pool = var.vm_libvirt_pool

  user_data = data.template_file.vm_cloudinit.rendered
}

resource "libvirt_domain" "domain" {
  name   = var.vm_hostname
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.init_disk.id // Attach cloud-init disk

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  dynamic "disk" {
    for_each = var.vm_disk_passthroughs
    content {
      block_device = disk.value
    }
  }

  network_interface {
    macvtap        = var.vm_libvirt_external_interface
    hostname       = var.vm_hostname
    wait_for_lease = false
    mac            = var.vm_mac // For some providers, this is required
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = var.vm_spice_server_enabled ? "address" : "none"
  }

}

resource "ansible_host" "default" {
  name   = coalesce(var.ansible_name, var.vm_hostname)
  groups = concat(var.ansible_groups, [var.vm_domain])

  variables = {
    ansible_host = coalesce(var.ansible_host, "${var.vm_ip}", "${var.vm_hostname}.${var.vm_domain}")
    ansible_user = "root"
  }
}
