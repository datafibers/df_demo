#!/bin/bash

if [ -z `which javac` -o "$(java -version 2>&1 | sed 's/.*version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')" -ge 18 ]; then 
    echo "install java 8"
fi