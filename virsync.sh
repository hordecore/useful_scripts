#!/bin/bash

# Бэкапятся только виртуальные машины с флагом autostart
# Можно переправить эту логику в строке 76, главное передать на
# stdin while read'а построчно список виртуальных машин

REMOTEHOST=10.0.0.44
MACHINES="/etc/rdiff-backup/machines"
BACKUPDIR="/backups/backups/${1:-daily}/"
MAIL="mail@example.com"

if ! ping -c 1 $REMOTEHOST; then
  ALARM "! ping -c 1 $REMOTEHOST"
	exit 3
fi

ALARM() {
	echo $@
	echo $@ >> /tmp/sendtomail
}

SSH() {
	echo $@ | ssh root@$REMOTEHOST
}

mkdir -p "$BACKUPDIR" 

ALARM "Start time: $(date +%H:%M:%S)"

while read MACHINE; do
	# собираем данные
	mkdir -p "${BACKUPDIR}/${MACHINE}/xml/" 
	SSH "virsh dumpxml $MACHINE" > "$BACKUPDIR$MACHINE/xml/$MACHINE.xml"
	# паузим виртуалку
	SSH "virsh save $MACHINE /tmp/$MACHINE" 

	# ждём пока она вырубится
	ITERATION=0
	while true; do
		date >&2
		SSH "virsh list" | grep -w "$MACHINE "
		[ $? = 0 ] && sleep 10 || break
		((ITERATION++))
		[ "$ITERATION" -gt 30 ] && break
	done
	[ "$ITERATION" -gt 30 ] && break

	# забираем rsync'ом диски
	for i in $(egrep -o "/.*(img|qcow|qcow2)" "$BACKUPDIR$MACHINE/xml/$MACHINE.xml"); do
		LDIR="${BACKUPDIR}/${MACHINE}/"
		mkdir -p "$LDIR" 
		ALARM Starting: rsync --compress-level=2 --block-size 32000 -P -avz "root@$REMOTEHOST:$i" "$LDIR"
		rsync --compress-level=2 --block-size 32000 -P -avz "root@$REMOTEHOST:$i" "$LDIR"
		find $BACKUPDIR -name "$PATTERN" &>/dev/null && ALARM "Successful $i in $LDIR" || ALARM "FAIL!!! $BACKUPDIR NO $PATTERN ALLES KAPUTEN!"
		ALARM '... Done!'
		SSH "rm -f $RDIR$PATTERN" 
	done 

	SSH "virsh restore /tmp/$MACHINE; rm -f /tmp/$MACHINE" 
done <<< "$(SSH "ls /etc/libvirt/qemu/autostart/ | sed -e 's/.xml//g'")"

ALARM "End time: $(date +%H:%M:%S)"

message="$(echo -e 'Backup log:\n';  cat /tmp/sendtomail)"

if [ -n "$message" ]; then
	# subject="Subject: Паника ужас безумие не сработал бэкап"
	subject="Subject: Результат бэкапов $(date)"
	echo -e "$subject \n\n $message" | msmtp $MAIL
	sleep 2
	rm -f /tmp/sendtomail
fi 

# принудительно ещё раз стартанём все виртуалки, возможно стоит удалять save и start
while read MACHINE; do
	SSH "virsh start $MACHINE" 
done < $MACHINES
