# Configure the VMware vSphere Provider for ISO deployment
terraform {
  required_version = ">= 0.13"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}

# Configure the vSphere provider
provider "vsphere" {
  user                 = "jamesde@tekchallenge.local"
  password             = "123456"
  vsphere_server       = "cs-vcsa01.tekchallenge.local"
  allow_unverified_ssl = true
}

# Data sources to get vSphere objects
data "vsphere_datacenter" "datacenter" {
  name = "Support Services"  # Update with your actual datacenter name
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Support Services 02"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = "STR-AFA01-V02"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Network data source
data "vsphere_network" "network" {
  name          = "VM Network"  # Update with your actual network name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Folder for VM placement
data "vsphere_folder" "folder" {
  path = "PH Core"  # Update path as needed
}

# ISO datastore for Windows Server 2022
data "vsphere_datastore" "iso_datastore" {
  name          = "STR-SAS01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Create the virtual machine from scratch
resource "vsphere_virtual_machine" "vm" {
  name             = "james_delamerced_winserver2022_x64"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = data.vsphere_folder.folder.path

  # VM Hardware Configuration
  num_cpus               = 2      # Recommended for Windows Server 2022
  memory                 = 4096   # 4GB RAM - recommended minimum for Server 2022
  guest_id               = "windows9Server64Guest"  # Windows Server 2016+ (64-bit)
  firmware               = "bios"
  
  # Enable CPU and memory hot-add (optional)
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true

  # SCSI controller
  scsi_type = "lsilogic-sas"

  # Network interface
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "e1000e"  # Compatible with Windows Server 2022
  }

  # Primary disk (OS installation target)
  disk {
    label            = "disk0"
    size             = 60              # 60GB for OS - adjust as needed
    thin_provisioned = true            # Thin provision as requested
    eagerly_scrub    = false
  }

  # CD/DVD Drive with ISO
  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id
    path         = "ISO/Windows Server 2022x64/en_windows_server_2022x64_dvd_.iso"
  }

  # Boot configuration - boot from CD/DVD first for OS installation
  boot_delay = 5000  # 5 second boot delay for interaction

  # Power on after creation
  # Note: VM will boot from ISO and show Windows installation screen
  wait_for_guest_net_timeout = 0    # Don't wait for network (OS not installed yet)
  wait_for_guest_ip_timeout  = 0    # Don't wait for IP (OS not installed yet)
}

# Outputs
output "vm_name" {
  description = "Name of the created virtual machine"
  value       = vsphere_virtual_machine.vm.name
}

output "vm_moid" {
  description = "Managed Object ID of the VM"
  value       = vsphere_virtual_machine.vm.moid
}

output "installation_instructions" {
  description = "Next steps after VM creation"
  value = <<EOT
VM created successfully! Next steps:

1. VM will power on automatically and boot from the Windows Server 2022 ISO
2. Connect to VM console via vCenter Web Client
3. Follow Windows Server 2022 installation wizard:
   - Select installation language and region
   - Choose "Windows Server 2022 Standard/Datacenter" edition
   - Select "Custom: Install Windows only" installation type  
   - Choose the 60GB disk for installation
   - Complete the installation process
4. After installation:
   - Configure network settings
   - Set administrator password
   - Install VMware Tools
   - Apply Windows updates
   - Configure server roles as needed

VM Location: ${data.vsphere_folder.folder.path}
VM Name: ${vsphere_virtual_machine.vm.name}
ISO: Windows Server 2022 x64 mounted and ready
EOT
}

output "vm_hardware_summary" {
  description = "VM hardware configuration"
  value = {
    cpu_count    = vsphere_virtual_machine.vm.num_cpus
    memory_mb    = vsphere_virtual_machine.vm.memory
    disk_size_gb = 60
    guest_os     = "Windows Server 2016+ (64-bit)"
    iso_mounted  = "Windows Server 2022 x64"
  }
}

