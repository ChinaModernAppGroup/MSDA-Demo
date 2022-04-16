#!/bin/bash
if [[ -z "$HOST_IP" ]]; then
  echo "HOST_IP not set in etcd container. Setting it to 10.2.2.70 (IP address assigned in the Vagrantfile)"
  HOST_IP=10.2.2.70
fi

if [[ -z "$BIGIP" ]]; then
  echo "BIGIP IP address not set. Setting it to 10.1.10.249"
  BIGIP=10.1.10.249
fi

# HOST_IP=$(ip -f inet a show enp0s8 | grep -oP "(?<=inet ).+(?=\/)")
CURL='/usr/bin/curl'
OPTIONS='-s'
ETCD_KEYS_API="http://$HOST_IP:4001/v2/keys"
ETCD_MACHINES_API="http://$HOST_IP:4001/v2/machines"

# Change the username and password of BIG-IP API access
BIGIPPOST="$CURL -sk -u restfulapi:murgiw-goxzam-seNka9 -X POST https://${BIGIP}"
BIGIPDELETE="$CURL -sk -u restfulapi:murgiw-goxzam-seNka9 -X DELETE https://${BIGIP}"
BIGIPGET="$CURL -sk -u restfulapi:murgiw-goxzam-seNka9 -X GET https://${BIGIP}"

echo "watch event fired, action=$ETCD_WATCH_ACTION, value=$ETCD_WATCH_VALUE"

# Get the list of current BIGIP pool members
servers=$(${BIGIPGET}/mgmt/tm/ltm/pool/~Common~pool-etcd-demo/members | jq -c '.items[].name')
echo "BIGIP pool Members:"
echo $servers

# Get the IP etcd is listening on
endpoint=$($CURL $OPTIONS $ETCD_MACHINES_API)
echo "endpoint=$endpoint"
IFS=':/' read -ra list <<< "$endpoint"    #Convert string to array
etcdip=${list[3]}
echo "etcdip=$etcdip"

# Check for ETCD_WATCH_ACTION & act accordingly
if [[ $ETCD_WATCH_ACTION == "set" ]]; then
  IFS=':' read -ra list <<< "$ETCD_WATCH_VALUE"    #Convert string to array
  port=${list[1]}
  entry=$etcdip:$port
  #servers=($($CURL $OPTIONS ${STATUS_UPSTREAMS_API}/${upstreams}/servers | jq  -c '.[]' | jq '.server'))
  echo "existing pool member: ${servers[@]}"
  if [[ "${servers[@]}" =~ "$entry" ]]; then
    echo "$entry already in bigip !"
  else
    $BIGIPPOST/mgmt/tm/ltm/pool/~Common~pool-etcd-demo/members -H 'Content-Type: application/json' -d '{"name":"/Common/'$entry'"}'
    echo "Added $entry to bigip pool !"
  fi

elif [[ $ETCD_WATCH_ACTION == "delete" ]]; then
  # Loop through the NGINX upstreams and remove the ones not present in etcd
  #servers=($($CURL $OPTIONS ${STATUS_UPSTREAMS_API}/${upstreams}/servers | jq  -c '.[]'))
  for server in ${servers[@]}; do
    # Loop through the servers in etcd & check if $server exists
    etcdvalues=$($CURL $OPTIONS $ETCD_KEYS_API/http | jq --raw-output '.node.nodes[].value')
    found=0
    for value in ${etcdvalues[@]}; do
      IFS=':' read -ra list <<< $value    #Convert string to array
      port=${list[1]}
      echo "get port information: $port"
      entry=$etcdip:$port
      echo "entry in etcd: $entry"
      if [[ $server =~ $entry ]]; then
        echo "${server} matches etcd entry $entry"
        found=1
        break
      else
        continue
      fi
    done

    if [ $found -eq 0 ]; then
      server=$(echo $server | sed 's/\"//g')
      ${BIGIPDELETE}/mgmt/tm/ltm/pool/~Common~pool-etcd-demo/members/${server}
      echo "Removed $server from bigip pool!"
    fi
  done
fi
