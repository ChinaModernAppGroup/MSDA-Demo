#!/bin/bash
# Add authentication for demo

if [[ -z "$NACOS_IP" ]]; then
  echo "NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)"
  NACOS_IP=127.0.0.1
fi

echo $1
endPoint=$1
serviceName="msda.nacos.com"
nacos_login="$NACOS_IP:8848/nacos/v1/auth/login"

accessToken=$(curl -s -X POST $nacos_login -d 'username=nacos&password=nacos' | jq -c '.accessToken' | sed 's/\"//g')
#echo $accessToken
nacosAPI="http://$NACOS_IP:8848/nacos/v1/ns/instance?serviceName=$serviceName&ip=$endPoint&port=8080&ephemeral=false&accessToken="
#echo $nacosAPI
addResult=$(curl -X POST -s $nacosAPI$accessToken)
echo "endPoint $endPoint add: $addResult"

