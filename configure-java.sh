#!/bin/bash

# this script is just there to check that the correct Java config (TLS v1.1 etc.) has been correctly applied by the base install script
# it should not be necessary to use it

LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PATH=$LOCATION:$LOCATION/jre/jre1.8.0_321/bin:$PATH
JAVA_HOME=./jre/jre1.8.0_321
JRE_HOME=./jre/jre1.8.0_321

$LOCATION/jre/jre1.8.0_321/bin/ControlPanel
