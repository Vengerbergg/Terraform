resource "proxmox_vm_qemu" "new-vm" {
  name            = "terminator"
  desc = "Ubuntu Server"
  target_node = "proxmox"

  agent = 1

  clone = "terraform-2"
  cores = 1
  sockets = 1
  cpu = "host" 
  memory = 1024

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  disk{
   storage = "local-lvm"
   type = "virtio"
   size = "20G"
  }

  os_type = "cloud-init"
}



# Using a template to provision to Proxmox 
# Separate provider.tf and auto.tfvars files for sensitive data