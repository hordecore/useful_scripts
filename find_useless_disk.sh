#!/bin/bash

TMPFILE=/tmp/$(basename $0).$$
STORAGE=${1:-/qemu/img}

virsh list --all | tail -n +3 | while read num name state
do 
	if [ -n "$name" ]; then
		virsh dumpxml $name | egrep -ow "/.*.(qcow2|qcow|img)"
	fi
done > "$TMPFILE"

ls $STORAGE | while read disk
do
	grep -q $disk $TMPFILE || echo $disk
done

rm -f $TMPFILE
