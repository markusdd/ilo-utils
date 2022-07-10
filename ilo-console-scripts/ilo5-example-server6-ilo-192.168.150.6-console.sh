#!/bin/bash
ILO_SKIP_DEFAULTS=1 ILO_LOGIN=Administrator ILO_HOST=192.168.150.6 ILO_VERSION=5 $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../ilo-console.sh
