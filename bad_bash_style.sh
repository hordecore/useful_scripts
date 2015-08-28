#!/bin/bash

tmpfile=/tmp/bash_tmp_file

for i in ${1:-.}/*; do
	wc -l $i 2>/dev/null
done | while read num file; do
	> $tmpfile
	if [ "$num" -gt 100 ]; then
		echo "- more than 100 lines long" >> $tmpfile
	fi

	if egrep -q '^.{80,}$' $file; then
		echo "- have longer than 80 symbols in line" >> $tmpfile
	fi

	if [ -s $tmpfile ]; then
		echo "# $file"
		cat $tmpfile
		echo
	fi

	rm -f $tmpfile
done
