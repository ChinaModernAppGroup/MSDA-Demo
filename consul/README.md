# Demo to show F5 service discovery with Consul

These project include 4 demos shows F5 products being used in conjuction with Consul, a service discovery platform. 

- NGINX Plus with Consul API. Uses official demo: [NGINX-Demos/consul-api-demo at master · nginxinc/NGINX-Demos · GitHub](https://github.com/nginxinc/NGINX-Demos/tree/master/consul-api-demo). But original shell script has some problem so I made some modification.
* NGINX Plus with Consul DNS interface. Uses official demo: [NGINX-Demos/consul-api-demo at master · nginxinc/NGINX-Demos · GitHub](https://github.com/nginxinc/NGINX-Demos/tree/master/consul-api-demo)
* Big-IP with Consul API. Create based on **NGINX Plus with Consul API demo**.
* Big-IP with Consul DNS interface. Create based on **NGINX Plus with Consul API demo**.



### Manual Install

#### Prerequisites and Required Software

The following software needs to be installed:

* [Docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/install) if you are running this on a linux VM
* A Big-IP TMOS version > 11.5, and has a pool named *pool_consul* in *Common* partition.
* A virtual server with the pool *pool_consul*

#### Setting up the demo

1. Clone demo repo

2. Export this IP into an environment variable named HOST_IP by running the `$ export HOST_IP=x.x.x.x` command. This variable is used by the `docker-compose.yml` file.

3. Spin up the Consul, Registrator and NGINX Plus containers first:
   
   `$ docker-compose up -d`

4. Execute the following two `docker exec` commands to install [jq](https://stedolan.github.io/jq/) inside consul container
   
   ```
   docker exec -ti consul apk update
   docker exec -ti consul apk add jq
   ```

5. Spin up the nginxdemos/hello container which is the backend http service
   
   `$ docker-compose -f create-http-service.yml up -d`

6. Now follow the steps under section 'Running the demo'

## Running the demo

1. You should have a bunch of containers up and running now:
   
   ```
   $ docker ps
   CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                                                                                                                NAMES
   b663f7ac70be        nginxdemos/hello:latest         "nginx -g 'daemon off"   About an hour ago   Up About an hour    443/tcp, 0.0.0.0:32800->80/tcp                                                                                                       consulapidemo_http_1
   2059ad9a7926        gliderlabs/registrator:latest   "/bin/registrator con"   About an hour ago   Up About an hour                                                                                                                                         registrator
   dd4b1101bb66        progrium/consul:latest          "/bin/start -server -"   About an hour ago   Up About an hour    53/tcp, 0.0.0.0:8300->8300/tcp, 0.0.0.0:8400->8400/tcp, 8301-8302/tcp, 0.0.0.0:8500->8500/tcp, 8301-8302/udp, 0.0.0.0:8600->53/udp   consul
   ```

2. Go to `http://<VS-IP>` in your favorite browser window and that will take you to the hello container printing its hostname, IP Address and port number, request URI, local time of the webserver and the client IP address. If you would like to see all the services registered with consul go to `http://<HOST-IP>:8500`. 

3. Now scale up and scale down the http service using the commands below. Go to the Pool tab on Big-IP GUI and observe the change in the list of servers being added/removed from the backend group accordingly.
   
   ```
   $ docker-compose -f create-http-service.yml scale http=5
   $ docker-compose -f create-http-service.yml scale http=3
   ```

4. The way this works is using [Consul Watches](https://www.consul.io/docs/agent/watches.html), eveytime there is a change in the number of containers running the http service, an external handler which is a simple bash script (`script.sh`) gets invoked. This script gets the list of pool members using its status and pool_conf APIs, loops through all the http service containers registered with consul and adds them to the upstream group using Rest API if not present already. It also removes the pool members which are not present in Consul from Big-IP pool.

All the changes should be automatically reflected in the Big-IP config and show up on the Big-IP GUI.
