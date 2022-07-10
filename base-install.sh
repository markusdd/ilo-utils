#!/bin/bash

LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "This script will now locally (within this repo) install mitmproxy and JRE8 to make iLO console and web access function. (Ctrl+C to abort, Enter to continue)"
read -s

echo "Download tool archives..."
wget -P /tmp/mitmproxy.tar.gz "https://snapshots.mitmproxy.org/6.0.2/mitmproxy-6.0.2-linux.tar.gz"
wget -P /tmp/jre.tar.gz "https://download.macromedia.com/pub/coldfusion/java/java8/8u321/jre/jre-8u321-linux-x64.tar.gz"

echo "Extract..."
mkdir -p $LOCATION/jre
cd $LOCATION/jre
tar xf /tmp/jre.tar.gz
cd $LOCATION
tar xf /tmp/mitmproxy.tar.gz

echo "Remove archives from /tmp location..."
rm -f /tmp/jre.tar.gz
rm -f /tmp/mitmproxy.tar.gz

echo "Install local Java config to allow TLSv1.1 and disable cert checking..."
cp $LOCATION/deployment.config $LOCATION/jre/jre1.8.0_321/lib/
cp $LOCATION/deployment.properties $LOCATION/jre/jre1.8.0_321/lib/
