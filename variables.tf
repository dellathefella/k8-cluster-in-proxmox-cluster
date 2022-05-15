variable "kubernetes_version" {
  default = "1.23"
}


variable "proxmox_entry_point_ip" {
  default = "10.0.120.40"
}

variable "template_name" {
  default = "ubuntu-2004-cloudinit-template"
}

#Support for more than one master has not been implemented
variable "master_config" {
  type = list(object({
    name = string
    target_host = string
    vm_id = number
    cores = number
    memory = number
    storage_size = string
    storage_name = string
    containerfqdn = string
    subnet_mask = string
    container_ip_address = string
    gateway_ip_address = string
  }))
  default = [
    {
    cores = 2
    memory = 4096
    name = "k8s-master-1"
    target_host = "della1"
    vm_id = 301
    storage_size = "30G"
    storage_name = "local-lvm"
    containerfqdn = "k8s-master-1.master.local"
    subnet_mask = "22"
    container_ip_address = "10.0.120.80"
    gateway_ip_address = "10.0.120.1"
    },
  ]
}

variable "worker_config" {
  type = list(object({
    name = string
    target_host = string
    vm_id = number
    cores = number
    memory = number
    storage_size = string
    storage_name = string
    containerfqdn = string
    subnet_mask = string
    container_ip_address = string
    gateway_ip_address = string
  }))
  default = [
  {
    cores = 2
    memory = 4096
    name = "k8s-worker-1"
    target_host = "della2"
    vm_id = 302
    storage_size = "30G"
    storage_name = "local-lvm"
    containerfqdn = "k8s-worker-1.worker.local"
    subnet_mask = "22"
    container_ip_address = "10.0.120.71"
    gateway_ip_address = "10.0.120.1"
  },
  {
    cores = 2
    memory = 4096
    name = "k8s-worker-2"
    target_host = "della3"
    vm_id = 303
    storage_size = "30G"
    storage_name = "local-lvm"
    containerfqdn = "k8s-worker-2.worker.local"
    subnet_mask = "22"
    container_ip_address = "10.0.120.72"
    gateway_ip_address = "10.0.120.1"
  },
  {
    cores = 2
    memory = 4096
    name = "k8s-worker-3"
    target_host = "della4"
    vm_id = 304
    storage_size = "30G"
    storage_name = "local-lvm"
    containerfqdn = "k8s-worker-3.worker.local"
    subnet_mask = "22"
    container_ip_address = "10.0.120.73"
    gateway_ip_address = "10.0.120.1"
  },
  {
    cores = 2
    memory = 4096
    name = "k8s-worker-4"
    target_host = "della5"
    vm_id = 305
    storage_size = "30G"
    storage_name = "local-lvm"
    containerfqdn = "k8s-worker-4.worker.local"
    subnet_mask = "22"
    container_ip_address = "10.0.120.74"
    gateway_ip_address = "10.0.120.1"
  },
  ]
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}