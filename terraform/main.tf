# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
  }
}  # <- This closing brace was missing!

# Provider configuration
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Data sources to get vCenter objects
data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Example VM resource
resource "vsphere_virtual_machine" "example_vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  num_cpus = var.vm_cpu
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  
  disk {
    label            = "disk0"
    size             = var.vm_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    
    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }
      
      network_interface {
        ipv4_address = var.vm_ip_address
        ipv4_netmask = var.vm_netmask
      }
      
      ipv4_gateway = var.vm_gateway
      dns_server_list = var.dns_servers
    }
  }
}
