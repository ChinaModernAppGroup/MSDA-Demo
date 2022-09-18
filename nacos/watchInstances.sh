#!/bin/bash
if [[ -z "$NACOS_IP" ]]; then
  echo "NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)"
  NACOS_IP=127.0.0.1
fi

nacosAPI="http://$NACOS_IP:8848/nacos/v1/ns/instance/list?serviceName=msda.nacos.com"

curl -X GET -s $nacosAPI | jq . | grep "instanceId\":"

