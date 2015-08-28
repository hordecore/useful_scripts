#!/bin/bash

tmpfile=/tmp/bash_tmp_file

file_list() {
	for i in $1/*; do
		wc -l $i 2>/dev/null
	done
}

long_file() {
	[ "$num" -gt 100 ] && echo "- more than 100 lines long"
}

long_lines() {
	egrep -q '^.{80,}$' $file && echo "- have longer than 80 symbols in line"
}

trailing_spaces() {
	egrep -q '(\t| )+$' $file && echo '- have trailing spaces'
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
		trailing_spaces >> $tmpfile
		show_output $tmpfile $file
		rm -f $tmpfile
	done
}

file_list "${1:-.}" | analyse
