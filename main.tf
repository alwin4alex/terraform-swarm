data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "swarm_node" {
  count            = var.vm_count
  name             = "swarm-node-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 256 # Updated to 512 GiB
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "swarm-node-${count.index + 1}"
        domain    = "local"
      }

      network_interface {
        ipv4_address = "192.168.1.${100 + count.index}"
        ipv4_netmask = 22
      }

      ipv4_gateway = "192.168.1.1"
    }
  }

  lifecycle {
    ignore_changes = [network_interface]
  }
}

output "swarm_node_ips" {
  value = [for vm in vsphere_virtual_machine.swarm_node : vm.default_ip_address]
}