#!/bin/bash

LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PATH=$LOCATION:$LOCATION/jre/jre1.8.0_321/bin:$PATH
JAVA_HOME=./jre/jre1.8.0_321
JRE_HOME=./jre/jre1.8.0_321

### ILO VERSION
echo -n 'iLO Version'
if [[ ! -z "$ILO_VERSION" ]]; then
    if [[ -z "$ILO_SKIP_DEFAULTS" ]]; then
        echo -n " [$ILO_VERSION]: "
        read ILO_NEW_VERSION
        if [[ ! -z $ILO_NEW_VERSION ]]; then ILO_VERSION=$ILO_NEW_VERSION; fi;
    else
        echo ": $ILO_VERSION"
    fi;
else
    echo -n ': '
    read ILO_VERSION
fi;
if [[ -z "$ILO_VERSION" ]]; then
    echo "Empty host - aborted."
    exit 1
fi;

### HANDLE VERSION PICK
case $ILO_VERSION in
    "2")
        ILO_JAR=html/intgapp_228.jar; ;;
    "3")
        ILO_JAR=html/intgapp3_231.jar; ;;
    "4")
        ILO_JAR=html/intgapp4_232.jar; ;;
    "5")
        ILO_JAR=html/intgapp4_252.jar; ;;
    *)
        echo "iLO $ILO_VERSION is not supported"
        exit 1;
esac

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

### LOGIN
# While -i exists it's not portable
echo -n 'iLO Login'
if [[ ! -z "$ILO_LOGIN" ]]; then
    if [[ -z "$ILO_SKIP_DEFAULTS" ]]; then
        echo -n " [$ILO_LOGIN]: "
        read ILO_NEW_LOGIN;
        if [[ ! -z $ILO_NEW_LOGIN ]]; then ILO_LOGIN=$ILO_NEW_LOGIN; fi;
    else
        echo ": $ILO_LOGIN"
    fi;
else
    echo -n ': '
    read ILO_LOGIN
fi;
if [[ -z "$ILO_LOGIN" ]]; then
    echo "Empty login - aborted."
    exit 1
fi;

### PASSWORD
echo -n 'iLO Password: '
read -s ILO_PASSWORD
echo;

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
   mitmdump --ssl-insecure -p 9443 --mode reverse:$ILO_ADDRESS &
   socat TCP4-LISTEN:17990,fork,reuseaddr,bind=127.0.0.1 TCP4:$ILO_AUTOPROXY_HOST:17990 &
   socat TCP4-LISTEN:17988,fork,reuseaddr,bind=127.0.0.1 TCP4:$ILO_AUTOPROXY_HOST:17988 &
   sleep 2 # let mitmdump start
   ILO_ADDRESS="https://127.0.0.1:9443/"
fi;

ILO_SESSKEY=$(
  OPENSSL_CONF=openssl-conf.cnf curl -fsS\
    --insecure \
    "${ILO_ADDRESS}json/login_session" \
    --data "{\"method\":\"login\",\"user_login\":\"$ILO_LOGIN\",\"password\":\"$ILO_PASSWORD\"}" |
      sed 's/.*"session_key":"\([a-f0-9]\{32\}\)".*/\1/'
);
if [[ -z "$ILO_SESSKEY" ]]; then
    echo "Failed to retrieve key. Wrong password or banned?"
    exit 1
fi;


# normal mktemp will not work with higher Java security settings
ILO_JNLP="$HOME/.iLO.jnlp"

cat >"$ILO_JNLP" <<eof
<?xml version="1.0" encoding="UTF-8"?>
<jnlp spec="1.0+" codebase="$ILO_ADDRESS" href="">
<information>
    <title>Integrated Remote Console</title>
    <vendor>HPE</vendor>
    <offline-allowed></offline-allowed>
</information>
<security>
    <all-permissions></all-permissions>
</security>
<resources>
    <j2se version="1.5+" href="http://java.sun.com/products/autodl/j2se"></j2se>
    <jar href="${ILO_ADDRESS}${ILO_JAR}" main="false" />
</resources>
<property name="deployment.trace.level property" value="basic"></property>
<applet-desc main-class="com.hp.ilo2.intgapp.intgapp" name="iLOJIRC" documentbase="${ILO_ADDRESS}html/java_irc.html" width="1" height="1">
    <param name="RCINFO1" value="$ILO_SESSKEY"/>
    <param name="RCINFOLANG" value="en"/>
    <param name="INFO0" value="7AC3BDEBC9AC64E85734454B53BB73CE"/>
    <param name="INFO1" value="17988"/>
    <param name="INFO2" value="composite"/>
</applet-desc>
 <update check="background"></update>
</jnlp>
eof


echo "Starting iLO console..."
if [[ ! -z "$ILO_AUTOPROXY" ]]; then
    echo "Console will appear soon. DO NOT close this window! (using autoproxy)"
    javaws -wait $ILO_JNLP; rm $ILO_JNLP
else
    # javaws -wait $ILO_JNLP; rm $ILO_JNLP
    nohup sh -c "/usr/bin/env javaws -wait $ILO_JNLP; rm $ILO_JNLP" >/dev/null 2>&1 &
    #echo "Console started. You CAN close this window."
fi;


