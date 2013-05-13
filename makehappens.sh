#!/bin/bash

# проверка наличия необходимых утилит
check_requirements() {
	[ ! -x `which wget` ] && echo 'No wget, no ithappens!' && exit 1
	[ ! -x `which wkhtmltopdf` ] && echo 'No wkhtmltopdf, no ithappens!' && exit 2
}

# вытягивание сырого кода контента
get_content() {
	mkdir /tmp/ithappens_wget/
	cd /tmp/ithappens_wget/
	for ((i=1144; i>0; i--)); do 
		wget http://ithappens.ru/page/$i -O $i; 
	done
}

# выдёргиваем из оригинального контента только то, что нам нужно
parse_content() {
	ls [0-9]* | sort -n | xargs cat | egrep "(<p class=.*text|<h3)" >> final.html.tmp
}

# генерируем полноценную html, чтобы никакие конвертеры не сходили с ума из-за кодировок
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

# с помощью wkhtmltopdf конвертируем из html в pdf (кэпкоммент)
convert_to_pdf() {
	touch ithappens.pdf
	wkhtmltopdf -s Letter final.html ithappens.pdf
	cp ithappens.pdf ~/
	echo "Your file is ready to read: $HOME/ithappens.pdf"
}

# с помощью html2text конвертируем в чистый текст и немного меняем переносы строк
convert_to_txt() {
	:
	#todo найти нужную регулярку + вызов html2text
}

# выполняем всё что нам нужно
main() {
	check_requirements
	get_content
	parse_content
	prepare_content
	convert_to_pdf
}

main
