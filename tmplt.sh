#!/bin/bash

TMPLOG=/tmp/${0##*/}.log
> $TMPLOG
LOGILE=/var/log/${0##*/}.log

terminate() {
        local retval=$1; shift
        echo -e "$@\n"
        cat "$TMPLOG" >> "$LOGFILE"
        rm -f "$TMPLOG"
        exit $retval
}

LOG() {
        echo $@ >> "$TMPLOG"
}

opts_parse() {
        case $1 in
                '--help' | '--usage' | '-h' )
                        echo 'Usage:'
                        printf "%30s" ' --help | --usage | -h'
                        echo 'Show this message'
                        ;;
        esac
}

main() {
        #add your logic here
        if [ "$#" = 0 ]; then
                terminate 1 "Пример - сделано ничего, несмотря на вызов с параметрами $@, попробуйте --help"
                echo "Выше этой надписи - вызов terminate"
        fi
}

opts_parse $@
main $@
cat $TMPLOG >> $LOGFILE
