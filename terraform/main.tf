# terraform/outputs.tf

output "vm_name" {
  description = "Name of the created virtual machine"
  value       = vsphere_virtual_machine.vm.name
}

output "vm_moid" {
  description = "Managed Object ID of the VM"
  value       = vsphere_virtual_machine.vm.moid
}

output "vm_uuid" {
  description = "UUID of the created virtual machine"
  value       = vsphere_virtual_machine.vm.uuid
}

output "vm_power_state" {
  description = "Power state of the virtual machine"
  value       = vsphere_virtual_machine.vm.power_state
}

output "vm_cpu_count" {
  description = "Number of CPUs assigned to the VM"
  value       = vsphere_virtual_machine.vm.num_cpus
}

output "vm_memory_mb" {
  description = "Memory in MB assigned to the VM"
  value       = vsphere_virtual_machine.vm.memory
}

output "vm_disk_size_gb" {
  description = "Disk size in GB"
  value       = vsphere_virtual_machine.vm.disk[0].size
}

output "vm_folder" {
  description = "Folder where the VM is located"
  value       = vsphere_virtual_machine.vm.folder
}

output "vm_datastore" {
  description = "Datastore where the VM is located"
  value       = data.vsphere_datastore.datastore.name
}

output "vm_network" {
  description = "Network the VM is connected to"
  value       = data.vsphere_network.network.name
}

output "vm_hardware_summary" {
  description = "VM hardware configuration"
  value = {
    cpu_count          = vsphere_virtual_machine.vm.num_cpus
    memory_mb          = vsphere_virtual_machine.vm.memory
    disk_size_gb       = var.vm_disk_size
    guest_os           = var.guest_id
    firmware           = var.firmware
    scsi_type          = var.scsi_type
    network_adapter    = var.network_adapter_type
    thin_provisioned   = var.thin_provisioned
    cpu_hot_add        = var.cpu_hot_add_enabled
    memory_hot_add     = var.memory_hot_add_enabled
  }
}

output "iso_information" {
  description = "Information about the mounted ISO"
  value = {
    iso_path       = var.iso_path
    iso_datastore  = data.vsphere_datastore.iso_datastore.name
    boot_delay_ms  = var.boot_delay
  }
}

output "snapshot_id" {
  description = "ID of the initial snapshot (if created)"
  value       = var.create_snapshot ? vsphere_virtual_machine_snapshot.vm_snapshot[0].id : null
}

output "installation_instructions" {
  description = "Next steps after VM creation"
  value = <<EOT
🎉 VM created successfully! Next steps:

📋 VM DETAILS:
   • Name: ${vsphere_virtual_machine.vm.name}
   • Location: ${vsphere_virtual_machine.vm.folder}
   • CPU: ${vsphere_virtual_machine.vm.num_cpus} vCPUs
   • Memory: ${vsphere_virtual_machine.vm.memory} MB
   • Disk: ${var.vm_disk_size} GB (thin provisioned: ${var.thin_provisioned})
   • ISO: ${var.iso_path}

🚀 INSTALLATION PROCESS:
   1. VM will power on automatically and boot from the Windows Server 2022 ISO
   2. Connect to VM console via vCenter Web Client
   3. Follow Windows Server 2022 installation wizard:
      → Select installation language and region
      → Choose "Windows Server 2022 Standard/Datacenter" edition
      → Select "Custom: Install Windows only" installation type  
      → Choose the ${var.vm_disk_size}GB disk for installation
      → Complete the installation process
   
🔧 POST-INSTALLATION TASKS:
   4. After installation:
      → Set administrator password
      → Configure network settings
      → Install VMware Tools (recommended)
      → Apply Windows updates
      → Configure server roles as needed
      → Join domain if required

💡 QUICK ACCESS:
   • vCenter: Connect to VM console for installation
   • Snapshot: ${var.create_snapshot ? "Initial snapshot created" : "No snapshot created"}
   • Boot Delay: ${var.boot_delay / 1000} seconds (time to press F2 for BIOS if needed)

⚠️  IMPORTANT NOTES:
   • VM boots from ISO first - Windows installation will start automatically
   • Installation typically takes 15-30 minutes
   • VM will require manual OS installation steps
   • Network connectivity will be available after OS installation and configuration
EOT
}

output "vm_access_info" {
  description = "Information for accessing the VM"
  value = {
    vm_name           = vsphere_virtual_machine.vm.name
    vm_moid          = vsphere_virtual_machine.vm.moid
    datacenter       = var.datacenter_name
    cluster          = var.cluster_name
    folder           = var.vm_folder_path
    vcenter_server   = var.vsphere_server
    console_access   = "Connect via vCenter Web Client console"
    installation_iso = var.iso_path
  }
}
