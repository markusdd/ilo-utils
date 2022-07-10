#!/bin/bash
LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PATH=$LOCATION:$LOCATION/jre/jre1.8.0_333/bin:$PATH
JAVA_HOME=./jre/jre1.8.0_333
JRE_HOME=./jre/jre1.8.0_333

$LOCATION/jre/jre1.8.0_333/bin/ControlPanel
