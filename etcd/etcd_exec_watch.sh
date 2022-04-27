#!/bin/bash
HOST_IP=$(ip -f inet a show ens38 | grep -oP "(?<=inet ).+(?=\/)")
etcdctl --no-sync --endpoint http://$HOST_IP:4001 exec-watch --recursive / -- sh -c ~/MSDA-Demo/etcd/script.sh;
