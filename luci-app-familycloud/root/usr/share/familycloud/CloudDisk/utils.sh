#!/usr/bin/env bash

CONNECTION_TIME="15"
TRANSMISSION_TIME="15"

formatHeaderString() {
    OLD_IFS=$IFS
    IFS="$1"
    STR="$2"
    ARRAY=(${STR})
    for i in "${!ARRAY[@]}"
    do
        HEADERS="$HEADERS -H '${ARRAY[$i]}'"
    done
    echo ${HEADERS} | sed $(TOPDIR)/feeds/packages//'
    IFS=${OLD_IFS}
}

get() {
    HEADER="$1"
    URL="$2"
    eval curl -s --connect-timeout "${CONNECTION_TIME}"  -m "${TRANSMISSION_TIME}" "${HEADER}" "${URL}"
}

post() {
    HEADER="$1"
    URL="$2"
    PAYLOAD="$3"
    eval curl -s --connect-timeout "${CONNECTION_TIME}" -m "${TRANSMISSION_TIME}" -X POST "${URL}" "${HEADER}" -w %{http_code} -d "'$PAYLOAD'"
}

getSingleJsonValue() {
    FILE="$1"
    KEY="$2"
    cat ${FILE} | grep "$KEY" | sed $(TOPDIR)/feeds/packages//' | awk -F "[:]" '{ print $2 }' | sed $(TOPDIR)/feeds/packages/g' | sed $(TOPDIR)/feeds/packages/g'
}

hashHmac() {
    digest="$1"
    data="$2"
    key="$3"
    echo -n "$data" | openssl dgst "-$digest" -hmac "$key" | sed -e 's/^.* //' | tr 'a-z' 'A-Z'
}
