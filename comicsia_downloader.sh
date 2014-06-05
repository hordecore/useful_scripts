#!/bin/bash

# example: comicsia_downloader.sh oglaf

set -eux

comix=$1
url=http://comicsia.ru/collections/$comix

download() {
        [ ! -f "$2" ] && wget "$1" -O "$2"
}

mkdir -p tmp/$comix.pages tmp/$comix.images
wget $url -O tmp/$comix.html
egrep -o "/collections/oglaf/[0-9]+" tmp/oglaf.html > tmp/$comix.pages.list


while read line; do
	download "http://comicsia.ru/$line" "tmp/$comix.pages/${line//'/'/_}"
done < tmp/$comix.pages.list

egrep -h -o http://.*.jpeg tmp/oglaf.pages/* > tmp/$comix.images.list

while read line1; do
        read line2
        read line3
	download "$line1" "tmp/$comix.images/${line1##*/}" &
        download "$line2" "tmp/$comix.images/${line2##*/}" &
        download "$line3" "tmp/$comix.images/${line3##*/}" &
        wait
done < tmp/$comix.images.list
