get_parsed_nomoney_list() {
        local redirect id ip policy
        while read line; do
                [[ "$line" = *address* ]] && unset id ip redirect policy && ip=${line//[^0-9.]/}
                [[ "$line" = *Circuit*clips* ]] id=${line##* }
                [[ "$line" = *HTTP-REDIRECT* ]] && policy=1
                [[ "$line" = *http-redirect-url* ]] && redirect="${line#* }" && redirect=${redirect% *}
                if [ "$redirect" = 'http://10.0.0.100/nomoney' -a "$policy" = '1' ]; then
                        echo $id $ip $redirect
                        unset id ip redirect policy
                fi
        done < /var/lib/event/files2/clips_detail.txt | sort
}
