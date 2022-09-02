#!/bin/bash

curl -X GET -s 'http://127.0.0.1:8848/nacos/v1/ns/instance/list?serviceName=msda.nacos.com' | jq . | grep "instanceId\":"

