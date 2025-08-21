# terraform/main.tf
terraform {
  required_version = ">= 1.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
  }
}

# Configure the VMware vSphere Provider
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Data source for datacenter
data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}

# Data source for datastore
data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Data source for compute cluster
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Data source for network
data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Data source for template
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Create a folder for organization (optional)
resource "vsphere_folder" "vm_folder" {
  path          = var.vm_folder_path
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Create the virtual machine
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.vm_folder.path

  num_cpus                = var.vm_cpu
  memory                  = var.vm_memory
  guest_id                = data.vsphere_virtual_machine.template.guest_id
  scsi_type               = data.vsphere_virtual_machine.template.scsi_type
  firmware                = data.vsphere_virtual_machine.template.firmware
  efi_secure_boot_enabled = data.vsphere_virtual_machine.template.efi_secure_boot_enabled

  # Network interface
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Disk configuration
  disk {
    label            = "disk0"
    size             = var.vm_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  # Clone from template
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

      ipv4_gateway    = var.vm_gateway
      dns_server_list = var.dns_servers
    }
  }

  # Wait for customization to complete
  wait_for_guest_net_timeout = 5
  wait_for_guest_ip_timeout  = 5
}

# Create a snapshot after VM creation (optional)
resource "vsphere_virtual_machine_snapshot" "vm_snapshot" {
  virtual_machine_uuid = vsphere_virtual_machine.vm.uuid
  snapshot_name        = "${var.vm_name}-initial-snapshot"
  description          = "Initial snapshot after VM creation"
  memory               = false
  quiesce              = true
  remove_children      = false
  consolidate          = true
}
