# Demo MSDA concept, Dynamic Reconfiguration NGINX Plus and F5 BIG-IP with etcd

This demo shows MSDA concept of dynamic configure NGINX Plus and F5 BIG-IP with etcd, a distributed, consistent key-value store for shared configuration and service discovery. This demo is based on docker and spins'
up the following containers:

*   [etcd](https://github.com/coreos/etcd) for service discovery
*   [Registrator](https://github.com/gliderlabs/registrator) to register services with etcd. Registrator monitors for containers being started and stopped and updates key-value pairs in etcd when a container changes state.
*   [nginxdemos/hello](https://hub.docker.com/r/nginxdemos/hello/) as a NGINX webserver that serves a simple page containing its hostname, IP address and port, request URI, local time of the webserver and the client IP address. This is to simulate backend servers NGINX Plus will be load balancing across.
*   [NGINX Plus](http://www.nginx.com/products) (R13 or higher)

All these components cited NGINX-Demos project [Demo to show NGINX Plus Dynamic Reconfiguration API with etcd](https://github.com/nginxinc/NGINX-Demos/tree/master/etcd-demo).

The NGINX plus demo is based off the work described in this blog post: [Service Discovery for NGINX Plus with etcd](https://www.nginx.com/blog/service-discovery-nginx-plus-etcd/). 


A standalone F5 BIG-IP (v15.1.x) is running outside of the host.

## Setup Options

### Manual Install

#### Prerequisites and Required Software

The following software needs to be installed:

*   [Docker for Mac](https://www.docker.com/products/docker#/mac) if you are running this locally on your MAC **OR** [docker-compose](https://docs.docker.com/compose/install) if you are running this on a linux VM
*   [jq](https://stedolan.github.io/jq/), I used [brew](http://brew.sh) to install it: `brew install jq`
*   [etcd](https://github.com/coreos/etcd) & etcdctl, a command line client for etcd. Follow the steps under 'Getting etcd' section and and copy over etcdctl executable under /usr/local/bin and make sure this path is present in $PATH variable

As the demo uses NGINX Plus a `nginx-repo.crt` and `nginx-repo.key` needs to be copied into the `nginxplus/` directory

#### Setting up the demo

1.  Clone demo repo

    `$ git clone https://github.com/ChinaModernAppGroup/MSDA-Demo.git`

2.  Copy `nginx-repo.key` and `nginx-repo.crt` files for your account to `~/MSDA-Demo/etcd/nginxplus/`

3.  Move into the demo directory:

    `$ cd ~/MSDA-Demo/etcd`

4.  If you have run this demo previously or have any docker containers running, start with a clean slate by running

    `$ ./clean-containers.sh`

5.  NGINX Plus will be listening on port 80 on docker host

    1.  If you are using Docker Toolbox, you can get the IP address of your docker-machine (default here) by running

    ```
    $ docker-machine ip default
    192.168.99.100
    ```

    2.  If you are using Docker for Mac, the IP address you need to use is 127.0.0.1

    **Export this IP into an environment variable named HOST_IP by running `export HOST_IP=x.x.x.x` command. This variable is used by docker-compose.yml file**
    
    **Export F5 BIG-IP IP address into an envoronment variable named BIGIP by runn `export BIGIP=y.y.y.y` command.**

6.  Spin up the etcd, Registrator and NGINX Plus containers first:

    `$ docker-compose up -d`

7.  To watch the etcd and configure NGINX plus, execute the etcd_exec_watch.sh script in background (This invokes an etcdctl exec-watch command watching for changes in etcd keys and trigger script.sh whenever a change is detected).

    `$ ./etcd_exec_watch.sh &`

8. To watch the etcd and configure F5 BIG-IP, execute the etcd_exec_watch_bigip.sh script in background (This invokes an etcdctl exec-watch command watching for changes in etcd keys and trigger script-bigip.sh whenever a change is detected).

    `$ ./etcd_exec_watch_bigip.sh &`

9. To watch the change in etcd, execute the follow command.

    `$ watch -d etcdctl --no-sync --endpoint http://$HOST_IP:4001 ls --recursive /http`

10. Spin up the nginxdemos/hello container which is the backend http service

    `$ docker-compose -f create-http-service.yml up -d`

11.  Now follow the steps under section 'Running the demo'

## Running the demo

1.  You should have a bunch of containers up and running now:

    ```
    $ docker ps
    CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                                                NAMES
    9fe2155fb33f        nginxdemos/hello:latest         "nginx -g 'daemon off"   5 seconds ago       Up 4 seconds        443/tcp, 0.0.0.0:32779->80/tcp                                       etcddemo_http_1
    20ae0c91237c        gliderlabs/registrator:latest   "/bin/registrator etc"   26 seconds ago      Up 25 seconds                                                                            registrator
    82f6a35d5212        etcddemo_nginxplus              "nginx -g 'daemon off"   26 seconds ago      Up 25 seconds       0.0.0.0:80->80/tcp, 0.0.0.0:8080->8080/tcp, 443/tcp                  nginxplus
    9fd1ab126773        quay.io/coreos/etcd:v2.0.8      "/etcd -name etcd0 -a"   26 seconds ago      Up 25 seconds       0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp, 7001/tcp   etcd
    ```

2.  Go to `http://<HOST_IP>` in your favorite browser window and that will take you to one of the nginx-hello containers printing its hostname, IP Address and the port of the container. `http://<HOST_IP>:8080/` will bring up the NGINX Plus dashboard. The configuration file NGINX Plus is using here is /etc/nginx/conf.d/app.conf which is included from /etc/nginx/nginx.conf. If you would like to see all the services registered with etcd you could do a `curl http://$HOST_IP:4001/v2/keys | jq '.'`. **We are also using the persistent on-the-fly reconfiguration introduced in NGINX Plus R8 using the [state](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#state) directive. This means that NGINX Plus will save the upstream conf across reloads by writing it to a file on disk.**

3.  Now scale up and scale down the http service using the commands below. Go to the Upstreams tab on Nginx Plus dashboard and observe the change in the list of servers being added/removed from the backend group accordingly.

     ```
     $ docker-compose -f create-http-service.yml up -d --scale http=5
     $ docker-compose -f create-http-service.yml up -d --scale http=3
     ```

4.  The way this works is everytime there is a change in etcd, script.sh gets triggered (through etcd_exec_watch.sh) which checks for some of the environment variables set by etcd and adds the server specified by ETCD_WATCH_VALUE to the NGINX upstream block if ETCD_WATCH_ACTION is 'set' and removes it if ETCD_WATCH_ACTION is 'delete'. The removal happens by traversing through all NGINX Plus upstreams and removing the ones not present in etcd.

All the changes should be automatically reflected in the NGINX config and show up on the NGINX Plus Dashboard.

All the changes should be automatically reflected in the F5 BIG-IP config and show up on the F5 BIG-IP Dashboard.

All the changes should be shown up in `watch -d etcdctl` terminal. 
