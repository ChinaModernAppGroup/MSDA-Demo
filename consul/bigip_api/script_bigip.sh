#!/bin/bash
if [[ -z "$HOST_IP" ]]; then
  echo "HOST_IP not set in consul container. Setting it to 10.1.10.227 (IP address assigned in the Vagrantfile)"
  HOST_IP=10.1.10.227
fi

BIGIP=10.1.1.244
CURL='/usr/bin/curl'
OPTIONS='-s'
OPTIONS_BIGIP='-sku admin:f5@2019'
CONSUL_SERVICES_API="http://$HOST_IP:8500/v1/catalog/services"
CONSUL_SERVICE_API="http://$HOST_IP:8500/v1/catalog/service"
STATUS_POOL_API="https://$BIGIP/mgmt/tm/ltm/pool/~Common~pool_consul/members"

# Get the list of current Big-IP pool
servers=$($CURL $OPTIONS_BIGIP ${STATUS_POOL_API})
echo "Pool members in pool_consul:"
echo $servers

# Loop through the registered servers in consul tagged with production (i.e backend servers to be proxied through nginx) and add the ones not present in the Nginx upstream block
service=$($CURL $OPTIONS $CONSUL_SERVICES_API | jq --raw-output 'to_entries | .[] | select(.value[0] == "production") | .key')
echo "Servers registered with consul:"
echo $service

ports=$($CURL $OPTIONS $CONSUL_SERVICE_API/$service | jq -r '.[] | .ServicePort')
for port in ${ports[@]}; do
  entry=$HOST_IP:$port
  if [[ ! $servers =~ $entry ]]; then
    $CURL -X POST -H 'Content-Type: application/json;charset=UTF-8' -d '{"name": "'$entry'"}' $OPTIONS_BIGIP "${STATUS_POOL_API}"
    echo "Added $entry to the Big-IP Pool pool_consul"
  fi
done

# Loop through the NGINX upstreams and remove the ones not present in consul
servers=($($CURL $OPTIONS_BIGIP ${STATUS_POOL_API} | jq  -c '.items[]'))
for params in ${servers[@]}; do
  if [[ $params =~ "name" ]]; then
    server=$(echo $params | jq -r '.name')
  else
    continue
  fi

  service=$($CURL $OPTIONS $CONSUL_SERVICES_API | jq --raw-output 'to_entries| .[] | select(.value[0] == "production") | .key')
  ports=$($CURL $OPTIONS $CONSUL_SERVICE_API/$service | jq -r '.[]|.ServicePort')
  found=0
  for port in ${ports[@]}; do
    entry=$HOST_IP:$port
    if [[ $server =~ $entry ]]; then
      echo "$server matches consul entry $entry"
      found=1
      break
    else
      continue
    fi
  done

  if [ $found -eq 0 ]; then
    $CURL -X DELETE $OPTIONS_BIGIP "${STATUS_POOL_API}/~Common~$server"
    echo "Removed $server from Big-IP Pool pool_consul!"
  fi
done