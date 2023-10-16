terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.4"
    }
    ansible = {
      version = "~> 1.0.0"
      source  = "ansible/ansible"
    }
  }
}
