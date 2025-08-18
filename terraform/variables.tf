# terraform/variables.tf

# vSphere connection variables
variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server URL"
  type        = string
}

variable "allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = true
}

# vSphere environment variables
variable "datacenter_name" {
  description = "Name of the datacenter"
  type        = string
  default     = "Datacenter"
}

variable "cluster_name" {
  description = "Name of the compute cluster"
  type        = string
  default     = "Cluster"
}

variable "datastore_name" {
  description = "Name of the datastore"
  type        = string
  default     = "datastore1"
}

variable "network_name" {
  description = "Name of the network"
  type        = string
  default     = "VM Network"
}

variable "template_name" {
  description = "Name of the VM template"
  type        = string
  default     = "ubuntu-20.04-template"
}

# VM configuration variables
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "terraform-vm"
}

variable "vm_cpu" {
  description = "Number of CPUs for the VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory in MB for the VM"
  type        = number
  default     = 4096
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "vm_ip_address" {
  description = "IP address for the VM"
  type        = string
  default     = "192.168.1.100"
}

variable "vm_netmask" {
  description = "Netmask for the VM"
  type        = number
  default     = 24
}

variable "vm_gateway" {
  description = "Gateway for the VM"
  type        = string
  default     = "192.168.1.1"
}

variable "vm_domain" {
  description = "Domain for the VM"
  type        = string
  default     = "local"
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}