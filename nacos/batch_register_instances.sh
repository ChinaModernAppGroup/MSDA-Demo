#!/bin/bash

echo $1
echo $2
serviceName="msda.nacos.com"

for value in {1..5}; do
    nacosAPI="http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=$serviceName&ip=10.1.10.4${value}&port=8080&ephemeral=false"
    addResult=$(curl -X POST -s $nacosAPI)
    echo "endPoint 10.1.10.4$value add: $addResult"
done
