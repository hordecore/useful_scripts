#!/bin/bash

for i in $(seq 1 12); do 
	LANG=C cal $i 2013 | grep -v "[a-z]" | while read t t t t t t day; do 
		[ -n "$day" ] && date +"%Y-%m-%d Воскресение" --date="2013-$i-$day"
	done
	LANG=C cal $i 2013 | grep -v "[a-z]" | while read t t t t t day t; do 
		[ -n "$day" ] && date +"%Y-%m-%d Суббота" --date="2013-$i-$day"
	done
done

if [ -f add.txt ]; then
	while read date name; do 
		echo "$date" "$name"
	done < weeks.txt
fi
