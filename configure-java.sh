#!/bin/bash
LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PATH=$LOCATION:$LOCATION/jre/jre1.8.0_321/bin:$PATH
JAVA_HOME=./jre/jre1.8.0_321
JRE_HOME=./jre/jre1.8.0_321

$LOCATION/jre/jre1.8.0_321/bin/ControlPanel
