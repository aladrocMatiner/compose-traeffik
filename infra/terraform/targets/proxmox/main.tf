provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_tls_insecure
}

locals {
  dns_servers = [
    for item in split(",", var.dns_servers_csv) : trimspace(item)
    if trimspace(item) != ""
  ]
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.proxmox_node_name
  on_boot   = var.proxmox_on_boot
  started   = true
  tags      = concat(["compose-traeffik", "managed"], var.proxmox_tags)

  vm_id = var.proxmox_vm_id > 0 ? var.proxmox_vm_id : null

  clone {
    vm_id        = var.proxmox_template_vm_id
    datastore_id = var.proxmox_clone_datastore_id
    full         = true
  }

  cpu {
    cores = var.vm_cpu
    type  = var.proxmox_cpu_type
  }

  memory {
    dedicated = var.vm_memory_mb
  }

  disk {
    datastore_id = var.proxmox_disk_datastore_id
    interface    = "scsi0"
    size         = var.vm_disk_gb
    iothread     = true
    discard      = "on"
  }

  network_device {
    bridge = var.proxmox_network_bridge
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = var.proxmox_cloudinit_datastore_id
    interface    = "ide2"

    user_account {
      username = var.ssh_user
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "${var.vm_ip}/${var.vm_cidr_prefix}"
        gateway = var.vm_gateway
      }
    }

    dns {
      servers = local.dns_servers
    }
  }
}
