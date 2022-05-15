resource "proxmox_vm_qemu" "worker_nodes" {
  count       = length(var.worker_config)
  name        = var.worker_config[count.index].name
  target_node = var.worker_config[count.index].target_host
  clone       = var.template_name
  vmid        = var.worker_config[count.index].vm_id
  cores       = var.worker_config[count.index].cores
  sockets     = 1
  memory      = var.worker_config[count.index].memory
  ssh_user        = "root"
  disk {
    size    = "${var.worker_config[count.index].storage_size}"
    type    = "scsi"
    storage = "${var.worker_config[count.index].storage_name}"
  }
  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

    sshkeys = file("~/.ssh/id_rsa.pub")
  # Cloud init options
    os_type = "cloud-init"
    ciuser = "bootstrap"
    ipconfig0 = "ip=${var.worker_config[count.index].container_ip_address}/${var.worker_config[count.index].subnet_mask},gw=${var.worker_config[count.index].gateway_ip_address}"
    
}

resource "proxmox_vm_qemu" "master_nodes" {
  count       = length(var.master_config)
  name        = var.master_config[count.index].name
  target_node = var.master_config[count.index].target_host
  clone       = var.template_name
  vmid        = var.master_config[count.index].vm_id
  cores       = var.master_config[count.index].cores
  sockets     = 1
  memory      = var.master_config[count.index].memory
  ssh_user        = "root"
  disk {
    size    = "${var.master_config[count.index].storage_size}"
    type    = "scsi"
    storage = "${var.master_config[count.index].storage_name}"
  }
  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  # Cloud init options
    sshkeys = file("~/.ssh/id_rsa.pub")
    os_type = "cloud-init"
    ciuser = "bootstrap"
    ipconfig0 = "ip=${var.master_config[count.index].container_ip_address}/${var.master_config[count.index].subnet_mask},gw=${var.master_config[count.index].gateway_ip_address}"
}

