#!/bin/bash

# mount carbon billing 5 / carbon xge router 5 qcow2 disk in host system
# usage: cb_mount.sh /qemu/img/Carbon_Billing_devel.qcow2
# 	 cb_mount.sh -u

set -eux

__mount() {
	disk="$1"
	sudo modprobe nbd max_part=10
	sudo qemu-nbd -c /dev/nbd0 $disk
	sudo mkdir -p /mnt/{appfs,basefs,bkfs,datafs,etcfs,logfs}
	sudo mount /dev/nbd0p2 /mnt/appfs
	sudo mount /dev/nbd0p1 /mnt/basefs
	sudo mount /dev/nbd0p3 /mnt/bkfs
	sudo mount /dev/nbd0p5 /mnt/datafs
	sudo mount /dev/nbd0p4 /mnt/etcfs
	sudo mount /dev/nbd0p6 /mnt/logfs
}

__umount() {
	for mount in /mnt/{appfs,basefs,bkfs,datafs,etcfs,logfs}; do
		sudo umount -f $mount
	done
}

if [ "$1" = '-u' ]; then
	__umount
	exit
fi

__mount $@
