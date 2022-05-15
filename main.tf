terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.1"
    }
  }
}

provider "proxmox" {
  # make sure to export PM_API_TOKEN_ID and PM_API_TOKEN_SECRET
  pm_tls_insecure = true
  pm_log_enable = true
  pm_api_url      = "https://${var.proxmox_entry_point_ip}:8006/api2/json"
}

#Deletes old injected vars before proceeding
resource "null_resource" "cleanup_injected_ansible_tooling" {
  provisioner "local-exec" {
    command = "rm -rf ansible/injected_inventory.ini ansible/generated_scripts/hostfile_injector"
  }
  depends_on = [
    proxmox_vm_qemu.worker_nodes,
    proxmox_vm_qemu.master_nodes,
  ]
}


#Generates some files before the ansible handoff stage
resource "local_file" "hostfile_injector" {
  filename = "${path.module}/ansible/generated_scripts/hostfile_injector.sh"
  file_permission = "777"
  content  = <<-EOT
    %{ for config in var.worker_config }
    echo "${config.container_ip_address}  ${config.containerfqdn} worker${index(var.worker_config,config)+1}" >> /etc/hosts
    %{ endfor }
    %{ for config in var.master_config }
    echo "${config.container_ip_address}  ${config.containerfqdn} master${index(var.master_config,config)+1}" >> /etc/hosts
    %{ endfor }
  EOT
  depends_on=[
    null_resource.cleanup_injected_ansible_tooling
  ]
}

#Build inventory based on containers generated from TFVARS
resource "local_file" "inventory_injector" {
  filename = "${path.module}/ansible/injected_inventory.ini"
  file_permission = "777"
  content  = <<-EOT
    [workers]
    %{ for config in var.worker_config }
    ${config.containerfqdn} ansible_host=${config.container_ip_address}
    %{ endfor }
    [masters]
    %{ for config in var.master_config }
    ${config.containerfqdn} ansible_host=${config.container_ip_address}
    %{ endfor }
    [masters:vars]

    ansible_user=bootstrap

    ansible_ssh_common_args='-o StrictHostKeyChecking=no'

    [workers:vars]

    ansible_user=bootstrap

    ansible_ssh_common_args='-o StrictHostKeyChecking=no'

  EOT
  depends_on=[
    null_resource.cleanup_injected_ansible_tooling
  ]
  
}

#Allows VMs to come online and start accepting connections
resource "time_sleep" "vm_timer" {
  depends_on = [
    local_file.hostfile_injector,
    proxmox_vm_qemu.worker_nodes,
    proxmox_vm_qemu.master_nodes,
  ]
  create_duration = "45s"
}

#Initates ansible handover
resource "null_resource" "ansible_handover" {
  provisioner "local-exec" {
    command = "ansible-playbook -i 'ansible/injected_inventory.ini' --private-key ${var.private_key_path} ansible/k8_cluster_setup.yaml"
  }
  depends_on = [
    time_sleep.vm_timer
  ]
}

#Removes tainted keys
resource "null_resource" "remove_tainted_keys" {
  provisioner "local-exec" {
    command = "ssh-keygen -f \"$HOME/.ssh/known_hosts\" -R \"${var.master_config[0].container_ip_address}\""
  }
  depends_on = [
    time_sleep.vm_timer,
    null_resource.ansible_handover
  ]
}

#Spits out the kube config into the home directory
resource "null_resource" "copy_kubectl" {
  provisioner "local-exec" {
    command = "cd ~; scp bootstrap@${var.master_config[0].container_ip_address}:/home/bootstrap/.kube/config config"
  }
  depends_on = [
    time_sleep.vm_timer,
    null_resource.ansible_handover,
    null_resource.remove_tainted_keys
  ]
}