resource "libvirt_volume" "cloudinit_image" {
  count  = var.cloudinit_image != "" ? 1 : 0
  name   = "${var.name}_cloudinit_image"
  pool   = var.libvirt_pool
  source = var.cloudinit_image
  format = "qcow2"
}

resource "libvirt_volume" "disk" {
  name           = "${var.name}_disk"
  pool           = var.libvirt_pool
  base_volume_id = try(libvirt_volume.cloudinit_image[0].id, "")
  size           = var.disk_size
}

data "template_file" "cloudinit_user_data" {
  template = <<-EOT
#cloud-config

%{if var.cloudinit_use_user_data == true~}


# From diademiemi/terraform-libvirt-vm
hostname: ${var.name}
%{if var.domain != null && var.domain != ""~}
fqdn: ${var.name}.${var.domain}
%{else~}
fqdn: ${var.name}
%{endif~}
prefer_fqdn_over_hostname: true

ssh_pwauth: ${var.password_auth}
ssh_deletekeys: False

%{if length(var.ssh_keys) > 0}
ssh_authorized_keys:
%{for key in var.ssh_keys}
  - "${key}"
%{endfor}
%{endif}

disable_root: ${var.disable_root}

%{if var.root_password != ""~}
chpasswd:
  list: |
     root:${var.root_password}
  expire: False
%{endif~}

%{if var.allow_root_ssh_pwauth != null && var.allow_root_ssh_pwauth == true}
bootcmd:
  - 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/99-allow-root-ssh-pwauth.conf'
%{endif}

%{endif~}

# Custom cloud-init
${coalesce(var.cloudinit_custom_user_data, "")}

EOT

}

data "template_file" "cloudinit_network_data" {
  template = <<-EOT
%{if var.cloudinit_use_network_data == true~}

version: 2
ethernets:
%{for interface in var.network_interfaces~}
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
      addresses:
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

%{endif~}

# Custom cloud-init
${coalesce(var.cloudinit_custom_network_data, "")}

EOT
}

resource "libvirt_cloudinit_disk" "init_disk" {
  name = "${var.name}_cloudinit"
  pool = var.libvirt_pool

  user_data      = data.template_file.cloudinit_user_data.rendered
  network_config = data.template_file.cloudinit_network_data.rendered
}

resource "libvirt_domain" "domain" {
  name   = var.domain != null && var.domain != "" ? "${var.name}.${var.domain}" : var.name
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

  dynamic "disk" {
    for_each = var.iso_urls
    content {
      url = disk.value
    }
  }

  dynamic "disk" {
    for_each = var.iso_paths
    content {
      file = disk.value
    }
  }

  boot_device {
    dev = ["hd", "cdrom", "network"]
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
    listen_type = var.spice_enabled ? "address" : "none"
  }

}

resource "ansible_host" "default" {
  name   = coalesce(var.ansible_name, var.name)
  groups = var.ansible_groups

  variables = {
    ansible_host     = coalesce(var.ansible_host, try(split("/", var.network_interfaces[0].ip).0, var.domain != null && var.domain != "" ? "${var.name}.${var.domain}" : var.name))
    ansible_user     = coalesce(var.ansible_user, "root")
    ansible_ssh_pass = coalesce(var.ansible_ssh_pass, var.root_password, "root")
    ansible_ssh_private_key_file = try(var.ansible_ssh_private_key_file, "")
  }
}
