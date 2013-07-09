#!/bin/bash

TMPLOG=/tmp/$(basename $0).log
> $TMPLOG
LOGILE=/var/log/$(basename $0).log

terminate() {
        local retval=$1
        shift
        echo "$@"
        echo
        cat $TMPLOG >> $LOGFILE
        rm -f "$TMPLOG"
        exit $retval
}

LOG() {
        echo $@ >> $TMPLOG
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
        opts_parse $@
        #add your logic here
        if [ "$#" = 0 ]; then
                terminate 1 "Пример - сделано ничего, несмотря на вызов с параметрами $@, попробуйте --help"
                echo "Выше этой надписи - вызов terminate"
        fi
}

main $@
cat $TMPLOG >> $LOGFILE
