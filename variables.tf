variable "libvirt_pool" {
  type    = string
  default = "default"
}

variable "disk_passthroughs" {
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

variable "nameservers" {
  type    = list(string)
  default = []
}

variable "libvirt_external_interface" {
  type    = string
  default = "eth0"
}

variable "dhcp" {
  type    = bool
  default = true
}

variable "ip" {
  type    = string
  default = ""
}

variable "gateway" {
  type    = string
  default = "" # 1.2.3.4/5
}

variable "mac" {
  type    = string
  default = null
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
