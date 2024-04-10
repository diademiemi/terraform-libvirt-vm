# DEFAULTS ARE *NOT* TO BE USED IN PRODUCTION AND ARE VERY INSECURE
variable "name" {
  type    = string
}

variable "domain" {
  type    = string
  default = null
  nullable = true
}

variable "cloudinit_image" {
  type    = string
  default = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
}

variable "libvirt_pool" {
  type    = string
  default = "default"
  nullable = false
}

variable "disk_passthroughs" {
  type    = list(string)
  default = []
  nullable = false
}

variable "iso_urls" {
  type    = list(string)
  default = []
  nullable = false
}

variable "iso_paths" {
  type    = list(string)
  default = []
  nullable = false
}

variable "ssh_keys" {
  type    = list(string)
  default = []
  nullable = false
}

variable "password_auth" {
  type    = bool
  default = true
  nullable = false
}

variable "disable_root" {
  type    = bool
  default = false
  nullable = false
}

variable "allow_root_ssh_pwauth" {
  type    = bool
  default = true
  nullable = false
}

variable "root_password" {
  type    = string
  default = "root"
  nullable = false
}

variable "nameservers" {
  type    = list(string)
  default = []
  nullable = false
}

variable "libvirt_external_interface" {
  type    = string
  default = null
}

variable "cloudinit_use_user_data" {
  type    = bool
  default = true
  nullable = false
}

variable "cloudinit_use_network_data" {
  type    = bool
  default = true
  nullable = false
}

variable "cloudinit_custom_user_data" {
  type    = string
  default = "# No user data\n"
  nullable = false
}

variable "cloudinit_custom_network_data" {
  type    = string
  default = "# No network user data\n"
  nullable = false
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
  nullable = false
}

variable "memory" {
  type    = number
  default = 2048
  nullable = false
}

variable "vcpu" {
  type    = number
  default = 2
  nullable = false
}

variable "disk_size" {
  type    = number
  default = 64424509440 # 60GB
  nullable = false
}

variable "spice_enabled" {
  type    = bool
  default = false
  nullable = false
}

variable "autostart" {
  type    = bool
  default = true
  nullable = false
}

variable "ansible_name" {
  type    = string
  default = ""
  nullable = false
}

variable "ansible_host" {
  type    = string
  default = ""
  nullable = false
}

variable "ansible_user" {
  type    = string
  default = "root"
  nullable = false
}

variable "ansible_ssh_pass" {
  type    = string
  default = ""
  nullable = false
}

variable "ansible_groups" {
  type = list(string)
  default = []
  nullable = false
}

variable "ansible_ssh_private_key_file" {
  type        = string
  description = "Defaults to null."
  default     = ""
  nullable = false
}
