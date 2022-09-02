#!/bin/bash

echo $1
endPoint=$1
serviceName="msda.nacos.com"

nacosAPI="http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=$serviceName&ip=$endPoint&port=8080&ephemeral=false"
addResult=$(curl -X POST -s $nacosAPI)
echo "endPoint $endPoint add: $addResult"
