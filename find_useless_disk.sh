#!/bin/bash

TMPFILE=/tmp/$(basename $0).$$
STORAGE=${1:-/qemu/img/}

virsh list --all | tail -n +3 | while read num name state
do
        if [ -n "$name" ]; then
                virsh dumpxml $name | egrep -ow "/.*.(qcow2|qcow|img)"
        fi
done > "$TMPFILE"

ls $STORAGE | grep -v *.xml | egrep  "(img|qcow|qcow2)" | while read disk
do
        if ! grep -q $disk $TMPFILE; then
                echo -e "$(du -s $STORAGE$disk | awk '{print $1}')\t$disk"
        fi
done | sort -n

rm -f $TMPFILE
