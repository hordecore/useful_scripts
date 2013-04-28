#!/bin/bash

TMPLOG=/tmp/$(basename $0).log
> $TMPLOG

terminate() {
        local retval=$1
        shift
        echo "$@"
        echo
        cat $TMPLOG
        rm -f "$TMPLOG"
        exit $retval
}

LOG() {
        echo $@ >> $TMPLOG
}

opts_parse() {
        if [ "$1" = '--help' -o "$1" = '--usage' -o "$1" = '-h' ]; then
                echo 'Usage:'
                printf "%30s" ' --help | --usage | -h'
                echo 'Show this message'
        fi
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
