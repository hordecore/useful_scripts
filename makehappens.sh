#!/bin/bash

[ ! -x `which wget` ] && echo 'No wget, no ithappens!' && exit 1
[ ! -x `which wkhtmltopdf` ] && echo 'No wkhtmltopdf, no ithappens!' && exit 2

get_content() {
	mkdir /tmp/ithappens_wget/
	cd /tmp/ithappens_wget/
	for ((i=1144; i>0; i--)); do 
		wget http://ithappens.ru/page/$i -O $i; 
	done
}

parse_content() {
	ls [0-9]* | sort -n | xargs cat | egrep "(<p class=.*text|<h3)" >> final.html.tmp
}

prepare_content() {
	cat > final.html <<EOF
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=cp1251">
		<link rel="stylesheet" type="text/css" href="ithappens.css" />
	</head>
	<body>
EOF

	cat final.html.tmp > final.html

	cat >> final.html <<EOF
	</body>
</html>
EOF
}

convert_to_pdf() {
	touch ithappens.pdf
	wkhtmltopdf -s Letter final.html ithappens.pdf
	cp ithappens.pdf ~/
	echo "Your file is ready to read: $HOME/ithappens.pdf"
}

main() {
	get_content
	parse_content
	prepare_content
	convert_to_pdf
}

main
