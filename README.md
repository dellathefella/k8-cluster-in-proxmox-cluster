# Deploy a K8 cluster in Proxmox Cluster using Terraform and Ansible
Running a kube cluster in any public cloud provider is a costly business.
There are many ways to deploy a local cluster with virtualbox, kind etc.
However I wanted to use Proxmox with my home server and I could not find any complete example of deploying a fully automated cluster using Terraform and Ansible.
# Retooling 
I have a 5 node Proxmox cluster and the original script is not really designed with that use case in mind.
Also I needed to be able to select the Kubernetes version which can be found in ansible/versions.yaml
Changed the up the tooling a bit to no longer rely on the very broken as of writing cicustom var in the proxmox provider.

# Pre-requisites
- Proxmox with API token to create VMs
- VM template (follow steps below to create a template)
- CIDR range to setup static IPs for the cluster nodes. Below are the default IPs.
- Proxmox Cluster
- SSH Keys generated on the deployer machine
```
[workers]

k8s-worker-1.worker.local ansible_host=10.0.120.71

k8s-worker-2.worker.local ansible_host=10.0.120.72

k8s-worker-3.worker.local ansible_host=10.0.120.73

k8s-worker-4.worker.local ansible_host=10.0.120.74

[masters]

k8s-master-1.master.local ansible_host=10.0.120.80

```
- Terraform and Ansible

# How to use this code
- Make sure you have all the pre-requisites
- Clone this repo
- Export PM_API_TOKEN_ID and PM_API_TOKEN_SECRET
```
export PM_API_TOKEN_ID="root@pam"'!'"token_name"
export PM_API_TOKEN_SECRET="something-7eeb-foof-9a68-probablyakey"
```
- Run Terraform init from the root folder
- Run Terraform apply

# Notes
- If you want to change the CIDR range/username etc, you may have to dig a little bit. I will update this documentation to make it easier at some point.
- Check the locations of the SSH keys, I used the usual default locations and file names ```( ~/.ssh/id_rsa )```
- Use MetalLB https://metallb.universe.tf/installation/ to play with Ingress and Ingress Controller.
- Use https://github.com/kubernetes-sigs/metrics-server metrics server, but make sure to update the deployment with ```--kubelet-insecure-tls``` arg to get it running. 
## How to create a VM template in Proxmox
## This is needed on every host that is going to deploy Kube workers.
```
mkdir -p /var/lib/vz/snippets/;
chmod 755 /var/lib/vz/snippets/;
export QMID=8001;
cd /var/lib/vz/template/iso; wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img;
# Download Ubuntu Focal
qm create $QMID --name "ubuntu-2004-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0;
# Create VM using image
qm importdisk $QMID focal-server-cloudimg-amd64.img local-lvm;
# Import image into VM
qm set $QMID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$QMID-disk-0;
# Set boot disk as disk
qm set $QMID --ide2 local-lvm:cloudinit;
# Add cloudinit
qm set $QMID --boot c --bootdisk scsi0;
# Set bootdisk
qm set $QMID --serial0 socket --vga serial0;
# Enable serial and serial
qm template $QMID
# Convert to template
```

#### Reference: #####
https://pve.proxmox.com/pve-docs/chapter-qm.html#_preparing_cloud_init_templates



