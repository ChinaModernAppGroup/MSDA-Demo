#!/bin/bash
if [[ -z "$HOST_IP" ]]; then
  echo "HOST_IP not set in consul container. Setting it to 10.1.10.227 (IP address assigned in the Vagrantfile)"
  HOST_IP=10.1.10.227
fi

BIGIP=10.1.1.244
CURL='/usr/bin/curl'
DRILL='/usr/bin/drill'
OPTIONS_BIGIP='-sku admin:f5@2019'
OPTIONS_DRILL='-t srv @127.0.0.1'
CONSUL_SERVICE="http.service.consul"
STATUS_POOL_API="https://$BIGIP/mgmt/tm/ltm/pool/~Common~pool_consul/members"

# Get the list of current Big-IP pool
servers=$($CURL $OPTIONS_BIGIP ${STATUS_POOL_API})
echo "Pool members in pool_consul:"
echo $servers

# Loop through the registered servers in consul tagged with production (i.e backend servers to be proxied through bigip) and add the ones not present in the bigip pool
$DRILL $OPTIONS_DRILL $CONSUL_SERVICE > /tmp/dns.txt

srv=0
while read line
do
  if [[ $srv -eq 1 ]]; then
    if [[ -n $line ]]; then
      port=$(echo $line | awk '{ print $7 }')
      entry=$HOST_IP:$port
      if [[ ! $servers =~ $entry ]]; then
        $CURL -X POST -H 'Content-Type: application/json;charset=UTF-8' -d '{"name": "'$entry'"}' $OPTIONS_BIGIP "${STATUS_POOL_API}"
        echo "Added $entry to the Big-IP Pool pool_consul"
      else
        continue
      fi
    else
      break
    fi
  elif [[ $line =~ "ANSWER SECTION" ]]; then
    srv=1
  else
    continue
  fi
done </tmp/dns.txt

# Loop through the bigip pool members and remove the ones not present in consul
servers=($($CURL $OPTIONS_BIGIP ${STATUS_POOL_API} | jq  -c '.items[]'))
for params in ${servers[@]}; do
  if [[ $params =~ "name" ]]; then
    server=$(echo $params | jq -r '.name')
  else
    continue
  fi

  srv=0
  found=0
  while read line
  do
    if [[ $srv -eq 1 ]]; then
      if [[ -n $line ]]; then
        port=$(echo $line | awk '{ print $7 }')
        entry=$HOST_IP:$port
        if [[ $server =~ $entry ]]; then
          echo "$server matches consul entry $entry"
          found=1
          break
        else
          continue
        fi
      else
        break
      fi
    elif [[ $line =~ "ANSWER SECTION" ]]; then
      srv=1
    else
      continue
    fi
  done </tmp/dns.txt

  if [ $found -eq 0 ]; then
    $CURL -X DELETE $OPTIONS_BIGIP "${STATUS_POOL_API}/~Common~$server"
    echo "Removed $server from Big-IP Pool pool_consul!"
  fi
done
