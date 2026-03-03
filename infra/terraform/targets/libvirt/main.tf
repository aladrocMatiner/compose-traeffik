provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  dns_servers = [
    for item in split(",", var.dns_servers_csv) : trimspace(item)
    if trimspace(item) != ""
  ]

  domain_xml_xslt_path = (
    var.libvirt_disable_apparmor_seclabel && var.libvirt_remove_ide_controller ? "${path.module}/domain-seclabel-none-and-remove-ide-controller.xslt" :
    var.libvirt_disable_apparmor_seclabel ? "${path.module}/domain-seclabel-none.xslt" :
    var.libvirt_remove_ide_controller ? "${path.module}/domain-remove-ide-controller.xslt" :
    ""
  )
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
    hostname             = var.hostname
    ssh_user             = var.ssh_user
    ssh_public_key       = var.ssh_public_key
    os_family            = var.os_family
    init_system          = var.init_system
    vm_ip                = var.vm_ip
    vm_cidr_prefix       = var.vm_cidr_prefix
    vm_gateway           = var.vm_gateway
    dns_servers          = local.dns_servers
    guest_interface_name = var.guest_interface_name
  })

  network_config = templatefile("${path.module}/../../../cloud-init/network-config.yaml.tftpl", {
    guest_interface_name = var.guest_interface_name
    vm_mac               = var.vm_mac
    vm_ip                = var.vm_ip
    vm_cidr_prefix       = var.vm_cidr_prefix
    vm_gateway           = var.vm_gateway
    dns_servers          = local.dns_servers
    os_family            = var.os_family
    init_system          = var.init_system
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
  firmware  = var.libvirt_firmware != "" ? var.libvirt_firmware : null
  machine   = var.libvirt_machine != "" ? var.libvirt_machine : null
  # Keep apply deterministic: guest agent may not be ready during first boot.
  qemu_agent = false

  dynamic "cpu" {
    for_each = var.libvirt_cpu_mode != "" ? [1] : []
    content {
      mode = var.libvirt_cpu_mode
    }
  }

  dynamic "xml" {
    for_each = local.domain_xml_xslt_path != "" ? [1] : []
    content {
      xslt = file(local.domain_xml_xslt_path)
    }
  }

  disk {
    volume_id = libvirt_volume.root_disk.id
  }

  dynamic "disk" {
    for_each = var.libvirt_attach_cloudinit_as_scsi ? [1] : []
    content {
      file = split(";", libvirt_cloudinit_disk.seed.id)[0]
      scsi = true
    }
  }

  cloudinit = var.libvirt_attach_cloudinit_as_scsi ? null : libvirt_cloudinit_disk.seed.id

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
