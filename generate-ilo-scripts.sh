#!/bin/bash

PROXY_IP=192.168.150.100
PORT_PREFIX=34

rm -f ilo-console-scripts/*-console.sh
cat README.md | grep -E "ilo(3|4|5) " | xargs -l1 bash -c 'echo \#\!/bin/bash > ilo-console-scripts/$0-$1-$2-console.sh; echo ILO_SKIP_DEFAULTS=1 ILO_LOGIN=Administrator ILO_HOST=$2 ILO_VERSION=${0: -1} \$\( cd -- \"\$\( dirname -- \"\$\{BASH_SOURCE\[0\]\}\" \)\" \&\> /dev/null \&\& pwd \)/../ilo-console.sh >> ilo-console-scripts/$0-$1-$2-console.sh'
chmod +x ilo-console-scripts/*-console.sh

rm -f ilo-ssh-scripts/*-ssh.sh
cat README.md | grep -E "ilo(3|4|5) " | xargs -l1 bash -c 'echo \#\!/bin/bash > ilo-ssh-scripts/$0-$1-$2-ssh.sh; echo ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-dss -oCiphers=+aes256-ctr -l Administrator $2 \"\$@\" >> ilo-ssh-scripts/$0-$1-$2-ssh.sh'
chmod +x ilo-ssh-scripts/*-ssh.sh

rm -f ilo-proxy-scripts/*-proxy.sh
cat README.md | grep -E "ilo3 " | xargs -l1 bash -c 'echo \#\!/bin/bash > ilo-proxy-scripts/$0-$1-$2-proxy.sh; echo ILO_SKIP_DEFAULTS=1 ILO_HOST=$2 \$\( cd -- \"\$\( dirname -- \"\$\{BASH_SOURCE\[0\]\}\" \)\" \&\> /dev/null \&\& pwd \)/../ilo-proxy.sh >> ilo-proxy-scripts/$0-$1-$2-proxy.sh'
chmod +x ilo-proxy-scripts/*-proxy.sh

rm -f ilo3-mitmproxy.sh
echo "#!/bin/bash" > ilo3-mitmproxy.sh;
cat README.md | grep -E "ilo3 " | PORT_PREFIX=$PORT_PREFIX xargs -l1 bash -c 'echo firewall-cmd --add-port=$PORT_PREFIX$(echo $2 | cut -f4 -d. | xargs printf "%03d")/tcp >> ilo3-mitmproxy.sh; echo mitmdump --set tls_version_server_min=TLS1_1  --set tls_version_server_max=TLS1_1 --set ciphers_server=AES128-SHA --ssl-insecure -p 34$(echo $2 | cut -f4 -d. | xargs printf "%03d") --mode reverse:https://$2:443/ \& >> ilo3-mitmproxy.sh'
chmod +x ilo3-mitmproxy.sh

rm -f ilo3-mitmproxy.service
echo "[Unit]" > ilo3-mitmproxy.service
echo "Description=MITM Proxies for iLO3 servers" >> ilo3-mitmproxy.service
echo "After=network.target" >> ilo3-mitmproxy.service
echo "" >> ilo3-mitmproxy.service
echo "[Service]" >> ilo3-mitmproxy.service
echo "Type=forking" >> ilo3-mitmproxy.service
echo "ExecStart=ilo3-mitmproxy.sh" >> ilo3-mitmproxy.service
echo "" >> ilo3-mitmproxy.service
echo "[Install]" >> ilo3-mitmproxy.service
echo "WantedBy=multi-user.target" >> ilo3-mitmproxy.service

# now patch the README.md to insert the links to all iLOs
# this is some sed black magic. yes it's ugly, but it works.
rm -f .ilolist.tmp
echo "" > .ilolist.tmp
cat README.md | grep -E "ilo3 " | PROXY_IP=$PROXY_IP PORT_PREFIX=$PORT_PREFIX xargs -l1 bash -c 'echo \- $1 - https://$PROXY_IP:$PORT_PREFIX$(echo $2 | cut -f4 -d. | xargs printf "%03d")/ >> .ilolist.tmp'
cat README.md | grep -E "ilo(4|5) " | PROXY_IP=$PROXY_IP PORT_PREFIX=$PORT_PREFIX xargs -l1 bash -c 'echo \- $1 - https://$2/ >> .ilolist.tmp'
echo "" >> .ilolist.tmp
# this contraption clears everything between the markers before we insert our file contents
sed -i '/^DO NOT EDIT - AUTOGENERATED/,/^END DO NOT EDIT - AUTOGENERATED/{/^DO NOT EDIT - AUTOGENERATED/!{/^END DO NOT EDIT - AUTOGENERATED/!d}}' README.md
sed -i -e '/^DO NOT EDIT - AUTOGENERATED/r .ilolist.tmp' README.md
rm -f .ilolist.tmp