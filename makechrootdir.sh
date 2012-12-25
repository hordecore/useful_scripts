#!/bin/bash

copy2chroot()
{
        path="$(which $1)"
	dirpath="$(dirname $path)"
	dirpath="${dirpath#/}"
	basename="$(basename $path)"
	mkdir -p "$dirpath"
	cp -arup "$path" "$dirpath"
	return 0
}

parse4ldd()
{
	ldd "$(which $1)" | grep -wo '/lib.* '
}

main()
{
	mkdir chrootdir
	while read lib; do
		( cd chrootdir; copy2chroot "$lib" )
	done <<< "$(parse4ldd "$1")"
}

main $@
