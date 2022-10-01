#!/bin/bash

if [[ -z "$NACOS_IP" ]]; then
  echo "NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)"
  NACOS_IP=127.0.0.1
fi

serviceName="msda.nacos.com"

if [[ -n "$1" ]]; then
  echo "Found namespaceId:$1, will expand it to servicename"
  serviceName="$serviceName&namespaceId=$1"
fi

nacos_login="$NACOS_IP:8848/nacos/v1/auth/login"
accessToken=$(curl -s -X POST $nacos_login -d 'username=nacos&password=nacos' | jq -c '.accessToken' | sed 's/\"//g')
#echo $accessToken

nacosAPI="http://$NACOS_IP:8848/nacos/v1/ns/instance/list?serviceName=$serviceName&accessToken=$accessToken"

curl -X GET -s $nacosAPI | jq . | grep "instanceId\":"

