variable "proxmox_api_url" {
  description = "Proxmox API endpoint (example: https://pve.example.com:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token as '<user@realm>!<tokenid>=<token-secret>'"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Allow insecure TLS when connecting to Proxmox API"
  type        = bool
  default     = false
}

variable "proxmox_node_name" {
  description = "Proxmox node name where the VM will be created"
  type        = string
}

variable "proxmox_template_vm_id" {
  description = "Existing cloud-init-ready template VM ID used as clone source"
  type        = number
}

variable "proxmox_vm_id" {
  description = "Optional static VM ID to assign to the created VM (0 lets Proxmox choose)"
  type        = number
  default     = 0
}

variable "proxmox_clone_datastore_id" {
  description = "Datastore ID used for the clone operation"
  type        = string
  default     = "local-lvm"
}

variable "proxmox_disk_datastore_id" {
  description = "Datastore ID used for the VM root disk"
  type        = string
  default     = "local-lvm"
}

variable "proxmox_cloudinit_datastore_id" {
  description = "Datastore ID used for the cloud-init drive"
  type        = string
  default     = "local-lvm"
}

variable "proxmox_network_bridge" {
  description = "Proxmox bridge name (for example vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "proxmox_on_boot" {
  description = "Start the VM automatically at node boot"
  type        = bool
  default     = true
}

variable "proxmox_cpu_type" {
  description = "CPU type passed to Proxmox VM"
  type        = string
  default     = "host"
}

variable "proxmox_tags" {
  description = "Extra Proxmox tags"
  type        = list(string)
  default     = []
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "hostname" {
  description = "Host metadata hostname"
  type        = string
}

variable "vm_ip" {
  description = "Static IPv4 address"
  type        = string
}

variable "vm_cidr_prefix" {
  description = "CIDR prefix length for vm_ip"
  type        = number
}

variable "vm_gateway" {
  description = "Default IPv4 gateway"
  type        = string
}

variable "dns_servers_csv" {
  description = "Comma-separated DNS servers"
  type        = string
  default     = "1.1.1.1,8.8.8.8"
}

variable "ssh_user" {
  description = "SSH username configured by cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  sensitive   = true
}

variable "vm_cpu" {
  description = "vCPU count"
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "Memory size in MB"
  type        = number
  default     = 2048
}

variable "vm_disk_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}
