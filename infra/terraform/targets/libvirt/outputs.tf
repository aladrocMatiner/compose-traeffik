output "host" {
  description = "Machine-readable host metadata for downstream automation"
  value = {
    target       = "libvirt"
    vm_name      = var.vm_name
    hostname     = var.hostname
    ip           = var.vm_ip
    ssh_user     = var.ssh_user
    ssh_port     = 22
    network_name = var.libvirt_network_name
    libvirt_uri  = var.libvirt_uri
  }
}

output "hosts" {
  description = "Future-friendly list output (single host in v1)"
  value = [{
    target       = "libvirt"
    vm_name      = var.vm_name
    hostname     = var.hostname
    ip           = var.vm_ip
    ssh_user     = var.ssh_user
    ssh_port     = 22
    network_name = var.libvirt_network_name
    libvirt_uri  = var.libvirt_uri
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
