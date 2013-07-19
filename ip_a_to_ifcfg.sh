#!/bin/bash

num2dotmask()
{
[[ $1 = *.* ]] && echo -n "$1" && return 0
  local A
  REZ=
  A=$1
  [ -z "$A" ] && return
  for i in 1 2 3 4 ; do
    if [ "$A" -ge 8 ] ; then
      A=$(( A - 8 ))
      REZ="$REZ""255."
    else
      case $A in
        0) REZ="$REZ""0."   ;;
        1) REZ="$REZ""128." ;;
        2) REZ="$REZ""192." ;;
        3) REZ="$REZ""224." ;;
        4) REZ="$REZ""240." ;;
        5) REZ="$REZ""248." ;;
        6) REZ="$REZ""252." ;;
        7) REZ="$REZ""254."
      esac
      A=0
    fi
  done
  echo -n "${REZ%.}"
  return
}

get_device() {
  ip a show $1 | head -1 | awk '{print $2}' | tr -d ':'
}

get_ipmask() {
	ip a show $1 | grep "inet " | awk '{print $2}' 
}

get_ip() {
	get_ipmask $1 | sed -e 's/\/.*//g'
}

get_nummask() {
	get_ipmask $1 | sed -e 's/.*\///g'
}

get_dotmask() {
	num2dotmask "$(get_nummask $1)"
}

isdefroute() {
	ip route show dev $1 | grep -q default
}

get_defroute() {
	ip route show dev $1 | fgrep default | awk '{print $3}'
}

get_dns() {
	DNSCOUNT=0
	grep nameserver /etc/resolv.conf | awk '{print $2}' | while read dns; do 
		((DNSCOUNT++))
		echo DNS$DNSCOUNT=$dns
	done
}

is_bridge() {
	brctl show | awk '{print $1}' | grep -qw $1
}

is_ether() {
	ip link show $1 | tail -1 | awk '{print $1}' | cut -d '/' -f2 | fgrep -qw ether
}

get_mac() {
	ip a show $1 | grep -owm1 ..:..:..:..:..:.. | grep -v ff:ff:ff:ff:ff:ff
}

in_bridge() {
	if ! is_bridge $1; then
		brctl show | grep -qw $1
	fi
}

get_bridge() {
	if in_bridge $1; then
		mac=$(get_mac $1)
		for $bridge in $(bridge_list); do
			if brctl showmacs $bridge | fgrep -wqm1 $mac; then
				echo $bridge
				return 0
			fi
		done
	fi	
}

bridge_list() {
	brctl show | awk '{print $1}' | grep -v 'bridge'
}

get_link_type() {
	if is_bridge $1; then
		echo Bridge
	elif is_ether $1; then
		echo Ethernet
	fi
}

make_output() {
	echo DEVICE=$(get_device $1)
	echo IPADDR=$(get_ip $1)
	echo NETMASK=$(get_dotmask $1)
	if isdefroute $1; then
		echo GATEWAY=$(get_defroute $1)
		echo "DEFROUTE=yes"
	fi
	get_dns
	echo TYPE=$(get_link_type $1)
	echo "ONBOOT=yes"
	echo "NM_CONTROLLED=no"
	if in_bridge $1; then
		echo BRIDGE=$(get_bridge $1)
	fi
}

make_output $1 > /tmp/$1
vimdiff /tmp/$1 /etc/sysconfig/network-scripts/ifcfg-$1
