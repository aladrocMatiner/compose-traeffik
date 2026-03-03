variable "libvirt_uri" {
  description = "Libvirt URI"
  type        = string
  default     = "qemu:///system"
}

variable "libvirt_pool" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "libvirt_network_name" {
  description = "Existing libvirt network name to attach the VM to"
  type        = string
  default     = "default"
}

variable "vm_name" {
  description = "Libvirt domain and disk name prefix"
  type        = string
}

variable "hostname" {
  description = "Hostname configured in cloud-init"
  type        = string
}

variable "vm_ip" {
  description = "Fixed IPv4 address for the VM"
  type        = string
}

variable "vm_cidr_prefix" {
  description = "CIDR prefix length for the VM IP"
  type        = number
}

variable "vm_gateway" {
  description = "Default IPv4 gateway"
  type        = string
}

variable "dns_servers_csv" {
  description = "Comma-separated DNS servers for the VM"
  type        = string
  default     = "1.1.1.1,8.8.8.8"
}

variable "vm_mac" {
  description = "MAC address used for libvirt NIC and cloud-init matching"
  type        = string
}

variable "guest_interface_name" {
  description = "Guest NIC name to set in cloud-init netplan"
  type        = string
  default     = "ens3"
}

variable "ssh_user" {
  description = "SSH user to create in the VM"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key content to install via cloud-init"
  type        = string
  sensitive   = true
}

variable "os_family" {
  description = "Guest OS family for cloud-init template branching"
  type        = string
  default     = "ubuntu"
}

variable "init_system" {
  description = "Guest init system (used by cloud-init template branching)"
  type        = string
  default     = ""
}

variable "ubuntu_image_path" {
  description = "Local path to the Ubuntu cloud image file"
  type        = string
}

variable "vm_cpu" {
  description = "vCPU count"
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "Memory (MB)"
  type        = number
  default     = 2048
}

variable "vm_disk_gb" {
  description = "Root disk size (GB)"
  type        = number
  default     = 20
}

variable "autostart" {
  description = "Whether the VM should autostart with libvirt"
  type        = bool
  default     = false
}

variable "libvirt_cpu_mode" {
  description = "Libvirt CPU mode; set empty to skip cpu block"
  type        = string
  default     = "host-passthrough"
}

variable "libvirt_firmware" {
  description = "Libvirt firmware mode (e.g. efi); empty to use provider default"
  type        = string
  default     = ""
}

variable "libvirt_machine" {
  description = "Libvirt machine type (e.g. q35); empty to use provider default"
  type        = string
  default     = ""
}

variable "libvirt_attach_cloudinit_as_scsi" {
  description = "Attach cloud-init ISO as a SCSI disk instead of using the cloudinit attr (useful for q35/UEFI)"
  type        = bool
  default     = false
}

variable "libvirt_remove_ide_controller" {
  description = "Strip IDE controller from generated domain XML (useful for q35)"
  type        = bool
  default     = false
}

variable "libvirt_pool_path" {
  description = "Filesystem path for the selected libvirt dir pool (used for ownership fixes)"
  type        = string
  default     = ""
}

variable "libvirt_qemu_user" {
  description = "QEMU user expected to own/read libvirt pool files"
  type        = string
  default     = "libvirt-qemu"
}

variable "libvirt_qemu_group" {
  description = "QEMU group expected to own/read libvirt pool files"
  type        = string
  default     = "kvm"
}

variable "libvirt_disable_apparmor_seclabel" {
  description = "Inject seclabel type=none (model=apparmor) to avoid local AppArmor pool access issues"
  type        = bool
  default     = true
}
