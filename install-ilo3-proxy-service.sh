#!/bin/bash

cp ilo3-mitmproxy.service /etc/systemd/system/
systemctl daemon-reload
systemctl stop ilo3-mitmproxy.service
cp ilo3-mitmproxy.sh /usr/bin
cp mitmdump /usr/bin
systemctl enable ilo3-mitmproxy.service
systemctl start ilo3-mitmproxy.service
