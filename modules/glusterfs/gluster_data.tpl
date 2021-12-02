#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo apt-get update
#update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo apt-get install -y software-properties-common python
DEVICE=/dev/$(lsblk -n | awk '$NF != "/" {print $1}' | tail -1)

mkfs -t xfs $DEVICE
mkdir  /glusterfs

mount $DEVICE /glusterfs
echo "$DEVICE xfs defaults 0 0"  >> /etc/fstab

mkdir -p /glusterfs/replica