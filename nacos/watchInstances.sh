#!/bin/bash
if [[ -z "$NACOS_IP" ]]; then
  echo "NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)"
  NACOS_IP=127.0.0.1
fi

accessToken=$(curl -s -X POST $nacos_login -d 'username=nacos&password=nacos' | jq -c '.accessToken' | sed 's/\"//g')
#echo $accessToken

nacosAPI="http://$NACOS_IP:8848/nacos/v1/ns/instance/list?serviceName=msda.nacos.com&accessToken="

curl -X GET -s $nacosAPI | jq . | grep "instanceId\":"

