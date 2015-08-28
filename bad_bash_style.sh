#!/bin/bash

tmpfile=/tmp/bash_tmp_file

file_list() {
	for i in $1/*; do
		wc -l $i 2>/dev/null
	done
}

long_file() {
	if [ "$num" -gt 100 ]; then
		echo "- more than 100 lines long"
	fi
}

long_lines() {
	if egrep -q '^.{80,}$' $file; then
		echo "- have longer than 80 symbols in line"
	fi
}

show_output() {
	if [ -s "${1:-$tmpfile}" ]; then
		echo "# ${2:-$file}"
		cat "${1:-$tmpfile}"
		echo
	fi
}

analyse() {
	while read num file; do
		> $tmpfile
		long_file >> $tmpfile
		long_lines >> $tmpfile
		show_output $tmpfile $file
		rm -f $tmpfile
	done
}

file_list "${1:-.}" | analyse
