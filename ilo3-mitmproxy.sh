#!/bin/bash
firewall-cmd --add-port=34001/tcp
mitmdump --set tls_version_server_min=TLS1_1 --set tls_version_server_max=TLS1_1 --set ciphers_server=AES128-SHA --ssl-insecure -p 34001 --mode reverse:https://192.168.150.1:443/ &
firewall-cmd --add-port=34002/tcp
mitmdump --set tls_version_server_min=TLS1_1 --set tls_version_server_max=TLS1_1 --set ciphers_server=AES128-SHA --ssl-insecure -p 34002 --mode reverse:https://192.168.150.2:443/ &
firewall-cmd --add-port=34003/tcp
mitmdump --set tls_version_server_min=TLS1_1 --set tls_version_server_max=TLS1_1 --set ciphers_server=AES128-SHA --ssl-insecure -p 34003 --mode reverse:https://192.168.150.3:443/ &
