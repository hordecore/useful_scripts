#!/bin/bash

set -eu

get_column_count() {
	local maxcol=0
	while read -a array; do
		[ ${#array[@]} -gt $maxcol ] && maxcol=${#array[@]}
	done < $file
	echo $maxcol
}

get_longest_word() {
	local word=''
	while read line; do
		[ "${#line}" -gt "${#word}" ] && word=$line
	done
	echo ${#word}
}

get_printf() {
	for col in $(seq 1 $maxcol); do
		word="$(awk '{print $'$col'}' < $file | get_longest_word)"
		echo -n "%$((word+1))s "
	done
	echo
}

file=$1
maxcol=$(get_column_count)
printf_line="$(get_printf)"

while read -a array; do
	printf "$printf_line\n" ${array[@]}
done < $file
