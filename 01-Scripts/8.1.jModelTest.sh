#!/bin/bash

#Set software and input paths
jModelTest=Path/jmodeltest-2.1.10/jModelTest.jar
file=Path/file.fas
java=Path/java

$java -jar $jModelTest -d $file -g 4 -i -f -AIC -BIC -a