variable "vm_libvirt_pool" {
  type    = string
  default = "default"
}

variable "vm_disk_passthroughs" {
  type    = list(string)
  default = []
}

variable "vm_ssh_keys" {
  type    = list(string)
  default = []
}

variable "vm_password_auth" {
  type    = bool
  default = false
}

variable "vm_nameservers" {
  type    = list(string)
  default = []
}

variable "vm_libvirt_external_interface" {
  type    = string
  default = "eth0"
}

variable "vm_dhcp" {
  type    = bool
  default = true
}

variable "vm_ip" {
  type    = string
  default = ""
}

variable "vm_gateway" {
  type    = string
  default = "" # 1.2.3.4/5
}

variable "vm_mac" {
  type    = string
  default = null
}

variable "vm_memory" {
  type    = number
  default = 2048
}

variable "vm_vcpu" {
  type    = number
  default = 2
}

variable "vm_disk_size" {
  type    = number
  default = 64424509440 # 60GB
}

variable "vm_cloudinit_image" {
  type    = string
  default = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
}

variable "vm_spice_server_enabled" {
  type    = bool
  default = false
}

variable "vm_hostname" {
  type    = string
  default = "libvirt_server"
}

variable "vm_domain" {
  type    = string
  default = "example.com"
}

variable "ansible_name" {
  type    = string
  default = "libvirt_server"
}

variable "ansible_host" {
  type    = string
  default = "libvirt_server.example.com"
}

variable "ansible_groups" {
  type    = list(string)
  default = [
    "libvirt",
  ]
}
