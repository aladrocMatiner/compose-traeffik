output "host" {
  description = "Machine-readable host metadata for downstream automation"
  value = {
    target          = "proxmox"
    vm_name         = var.vm_name
    hostname        = var.hostname
    ip              = var.vm_ip
    ssh_user        = var.ssh_user
    ssh_port        = 22
    proxmox_node    = var.proxmox_node_name
    proxmox_api_url = var.proxmox_api_url
    proxmox_vm_id   = proxmox_virtual_environment_vm.vm.vm_id
  }
}

output "hosts" {
  description = "Future-friendly list output (single host in v1)"
  value = [{
    target          = "proxmox"
    vm_name         = var.vm_name
    hostname        = var.hostname
    ip              = var.vm_ip
    ssh_user        = var.ssh_user
    ssh_port        = 22
    proxmox_node    = var.proxmox_node_name
    proxmox_api_url = var.proxmox_api_url
    proxmox_vm_id   = proxmox_virtual_environment_vm.vm.vm_id
  }]
}

output "host_ip" {
  value = var.vm_ip
}

output "ssh_user" {
  value = var.ssh_user
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${var.vm_ip}"
}
