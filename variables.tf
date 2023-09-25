variable "libvirt_pool" {
  type    = string
  default = "default"
}

variable "disk_passthroughs" {
  type    = list(string)
  default = []
}

variable "iso_urls" {
  type    = list(string)
  default = []
}

variable "iso_paths" {
  type    = list(string)
  default = []
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "password_auth" {
  type    = bool
  default = false
}

variable "disable_root" {
  type    = bool
  default = true
}

variable "allow_root_ssh_pwauth" {
  type    = bool
  default = false
}

variable "root_password" {
  type    = string
  default = ""
}

variable "nameservers" {
  type    = list(string)
  default = []
}

variable "libvirt_external_interface" {
  type    = string
  default = null
}

variable "cloudinit_use_user_data" {
  type    = bool
  default = true
}

variable "cloudinit_use_network_data" {
  type    = bool
  default = true
}

variable "cloudinit_custom_user_data" {
  type    = string
  default = ""
}

variable "cloudinit_custom_network_data" {
  type    = string
  default = ""
}

variable "network_interfaces" {
  type = list(object({
    name           = optional(string)
    network_id     = optional(string)
    network_name   = optional(string)
    macvtap        = optional(string)
    hostname       = optional(string)
    wait_for_lease = optional(bool)

    dhcp        = optional(bool)
    ip          = optional(string)
    gateway     = optional(string)
    nameservers = optional(list(string))
    mac         = optional(string)

    additional_routes = optional(list(object({
      network = string
      gateway = string
    })))
  }))
  default = []
}

variable "memory" {
  type    = number
  default = 2048
}

variable "vcpu" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 64424509440 # 60GB
}

variable "cloudinit_image" {
  type    = string
  default = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
}

variable "spice_server_enabled" {
  type    = bool
  default = false
}

variable "hostname" {
  type    = string
  default = "libvirt_server"
}

variable "domain" {
  type    = string
  default = ""
}

variable "autostart" {
  type    = bool
  default = true
}

variable "ansible_name" {
  type    = string
  default = ""
}

variable "ansible_host" {
  type    = string
  default = ""
}

variable "ansible_user" {
  type    = string
  default = "root"
}

variable "ansible_ssh_pass" {
  type    = string
  default = ""
}

variable "ansible_groups" {
  type = list(string)
  default = [
    "libvirt",
  ]
}
