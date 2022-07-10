#!/bin/bash

PATH=.:$PATH
ILO_AUTOPROXY=1

### HOST
echo -n 'iLO Host'
if [[ ! -z "$ILO_HOST" ]]; then
    if [[ -z "$ILO_SKIP_DEFAULTS" ]]; then
        echo -n " [$ILO_HOST]: "
        read ILO_NEW_HOST
        if [[ ! -z $ILO_NEW_HOST ]]; then ILO_HOST=$ILO_NEW_HOST; fi;
    else
        echo ": $ILO_HOST"
    fi;
else
    echo -n ': '
    read ILO_HOST
fi;
if [[ -z "$ILO_HOST" ]]; then
    echo "Empty host - aborted."
    exit 1
fi;

ILO_ADDRESS="$ILO_HOST"
if [[ ! "$ILO_ADDRESS" =~ ^"https://".* ]]; then ILO_ADDRESS="https://$ILO_ADDRESS"; fi;
if [[ ! "$ILO_ADDRESS" =~ .*"/$" ]]; then ILO_ADDRESS="$ILO_ADDRESS/"; fi;

### AUTO-PROXY
if [[ ! -z "$ILO_AUTOPROXY" ]]; then
    ILO_AUTOPROXY_HOST=$(echo $ILO_ADDRESS|cut -d/ -f3)

   if ! command -v mitmdump &> /dev/null; then
       echo "Cannot find mitmdump (part of mitmproxy package) - it is required for ILO_AUTOPROXY"
       exit 1
   fi

   if ! command -v socat &> /dev/null; then
       echo "Cannot find socat - it is required for ILO_AUTOPROXY"
       exit 1
   fi

   trap "kill 0" EXIT
   # See https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-a00045334en_us
   mitmdump --set tls_version_server_min=TLS1_1  --set tls_version_server_max=TLS1_1 --set ciphers_server=AES128-SHA --ssl-insecure -p 9443 --mode reverse:$ILO_ADDRESS &
   socat TCP4-LISTEN:17990,fork,reuseaddr,bind=127.0.0.1 TCP4:$ILO_AUTOPROXY_HOST:17990 &
   sleep 2 # let mitmdump start
   ILO_ADDRESS="https://127.0.0.1:9443/"
   echo "iLO3-Webpage served by iLO-Proxy:"
   echo $ILO_ADDRESS
   echo "Ctrl+C to exit"
   socat TCP4-LISTEN:17988,fork,reuseaddr,bind=127.0.0.1 TCP4:$ILO_AUTOPROXY_HOST:17988
fi;
