variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}
variable "template" {}

variable "vm_count" {
  default = 3
}

variable "vm_cpus" {
  default = 2
}

variable "vm_memory" {
  default = 4096
}

variable "vm_disk" {
  default = 40
}
