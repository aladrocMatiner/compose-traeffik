# Proxmox Terraform Target

This target provisions a VM on a remote Proxmox cluster by cloning an existing cloud-init-ready template VM.

## Requirements

- Proxmox VE reachable from this host.
- API token with permissions to clone/create VMs on the selected node/datastores.
- A cloud-init-capable template VM (`proxmox_template_vm_id`) already prepared in Proxmox.
- Terraform >= 1.5.

## Secrets handling

Do not commit credentials. Use one of:

- environment variables (`PROXMOX_API_URL`, `PROXMOX_API_TOKEN`, ...), or
- local `terraform.tfvars` (ignored by `.gitignore`) copied from `terraform.tfvars.example`.

## Example (via Make wrapper)

```bash
export PROXMOX_API_URL='https://pve.example.com:8006/api2/json'
export PROXMOX_API_TOKEN='root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
export PROXMOX_NODE_NAME='pve'
export PROXMOX_TEMPLATE_VM_ID='9000'

make deployment target=proxmox os=ubuntu \
  DEPLOYMENT_VM_NAME=compose-traeffik-ubuntu-pve \
  DEPLOYMENT_VM_IP=192.168.10.50 \
  DEPLOYMENT_VM_GATEWAY=192.168.10.1 \
  DEPLOYMENT_DNS_SERVERS=1.1.1.1,8.8.8.8
```

Outputs follow the same core shape as `libvirt` (`target`, `hostname`, `ip`, `ssh_user`).
