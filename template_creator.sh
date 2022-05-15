#QMID needs to be unique for each box
export QMID=8003
cd /var/lib/vz/template/iso; wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img;
qm create $QMID --name "ubuntu-2004-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0;
qm importdisk $QMID focal-server-cloudimg-amd64.img local-lvm;
qm set $QMID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$QMID-disk-0;
qm set $QMID --ide2 local-lvm:cloudinit;
qm set $QMID --boot c --bootdisk scsi0;
qm set $QMID --serial0 socket --vga serial0;
qm template $QMID
