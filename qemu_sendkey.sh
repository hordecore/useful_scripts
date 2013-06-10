#!/bin/bash


if [ "$#" = 0 -o "$1" = '--help' ]; then
	echo "Usage $(basename $0): <Domain> '<String>'"
	exit 66
fi

exec 1>/dev/null

MACHINE="$1"; shift

while IFS= read key; do
	[ "$key" = " " ] && key='spc'
	[ ! -n "$key" ] && continue
	virsh qemu-monitor-command --hmp "$MACHINE" "sendkey $key"
done <<< "$(echo "$*" | grep -o .)"
virsh qemu-monitor-command --hmp "$MACHINE" 'sendkey kp_enter'
