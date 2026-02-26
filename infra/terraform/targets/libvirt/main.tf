provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  dns_servers = [
    for item in split(",", var.dns_servers_csv) : trimspace(item)
    if trimspace(item) != ""
  ]
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "${var.vm_name}-ubuntu-base.qcow2"
  pool   = var.libvirt_pool
  source = var.ubuntu_image_path
  format = "qcow2"
}

resource "libvirt_volume" "root_disk" {
  name           = "${var.vm_name}.qcow2"
  pool           = var.libvirt_pool
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.vm_disk_gb * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "seed" {
  name = "${var.vm_name}-seed.iso"
  pool = var.libvirt_pool

  user_data = templatefile("${path.module}/../../../cloud-init/user-data.yaml.tftpl", {
    hostname       = var.hostname
    ssh_user       = var.ssh_user
    ssh_public_key = var.ssh_public_key
  })

  network_config = templatefile("${path.module}/../../../cloud-init/network-config.yaml.tftpl", {
    guest_interface_name = var.guest_interface_name
    vm_mac               = var.vm_mac
    vm_ip                = var.vm_ip
    vm_cidr_prefix       = var.vm_cidr_prefix
    vm_gateway           = var.vm_gateway
    dns_servers          = local.dns_servers
  })

  meta_data = <<-EOT
    instance-id: ${var.vm_name}
    local-hostname: ${var.hostname}
  EOT
}

resource "null_resource" "pool_permissions" {
  count = var.libvirt_pool_path != "" ? 1 : 0

  triggers = {
    pool_path    = var.libvirt_pool_path
    qemu_user    = var.libvirt_qemu_user
    qemu_group   = var.libvirt_qemu_group
    base_volume  = libvirt_volume.ubuntu_base.id
    root_volume  = libvirt_volume.root_disk.id
    cloudinit_id = libvirt_cloudinit_disk.seed.id
  }

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
        sudo chown -R "${var.libvirt_qemu_user}:${var.libvirt_qemu_group}" "${var.libvirt_pool_path}" || true
        sudo chmod -R u+rwX,g+rwX "${var.libvirt_pool_path}" || true
      else
        echo "[warn] sudo -n unavailable; skipping libvirt pool permission fix for ${var.libvirt_pool_path}" >&2
      fi
    EOT
  }
}

resource "libvirt_domain" "vm" {
  name      = var.vm_name
  memory    = var.vm_memory_mb
  vcpu      = var.vm_cpu
  autostart = var.autostart
  # Keep apply deterministic: guest agent may not be ready during first boot.
  qemu_agent = false

  dynamic "cpu" {
    for_each = var.libvirt_cpu_mode != "" ? [1] : []
    content {
      mode = var.libvirt_cpu_mode
    }
  }

  dynamic "xml" {
    for_each = var.libvirt_disable_apparmor_seclabel ? [1] : []
    content {
      xslt = file("${path.module}/domain-seclabel-none.xslt")
    }
  }

  disk {
    volume_id = libvirt_volume.root_disk.id
  }

  cloudinit = libvirt_cloudinit_disk.seed.id

  network_interface {
    network_name   = var.libvirt_network_name
    mac            = var.vm_mac
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  depends_on = [null_resource.pool_permissions]
}
