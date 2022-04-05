# O arquivo principal do app

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https//:pxhvmvv02:8006/api2/json"

  pm_api_token_id     = "terraform@pam!Tokenterraform"
  pm_api_token_secret = "5474816d-29c9-4ae5-ba17-726ec1b9e485"
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "test_server" {
  count = 1
  name  = "test-vm-${count.index + 1}"

  target_node = var.proxmox_host
  clone       = var.template_name

  agent    = 1
  os_type  = "ubuntu"
  cores    = 2
  sockets  = 1
  cpu      = "host"
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "SSD"
    iothread = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=10.50.20.50${count.index + 1}/24,gw=10.98.1.1"
  sshkeys   = <<EOF
    ${var.ssh_key}
    EOF
}
