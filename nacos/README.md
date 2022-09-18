# Setup Nacos server for testing

Follow up the offical doc to setup the nacos server in docker environment.

[nacos-docker](https://nacos.io/zh-cn/docs/quick-start-docker.html)

## Quick Start for Nacos Docker

### Steps

Run the following command：

Clone project

```
git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
```
Stand-alone Derby

`docker-compose -f example/standalone-derby.yaml up`
Stand-alone MySQL

To use MySQL 5.7, run

`docker-compose -f example/standalone-mysql-5.7.yaml up`
To use MySQL 8, run

`docker-compose -f example/standalone-mysql-8.yaml up`
Cluster

`docker-compose -f example/cluster-hostname.yaml up `
Service registration

`curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080'`
Service discovery

`curl -X GET 'http://127.0.0.1:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName'`
Publish config

`curl -X POST "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test&content=helloWorld"`
Get config

`  curl -X GET "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test"`
Open the Nacos console in your browser

link：[local nacos server](http://127.0.0.1:8848/nacos/)


1. Export environment variable for NACOS server

`export NACOS_IP=10.108.44.57`

2. Run register script to register some instances

```
$ ./register_instance.sh 10.1.10.40
10.1.10.40
endPoint 10.1.10.40 add: ok
$ ./register_instance.sh 10.1.10.41
10.1.10.41
endPoint 10.1.10.41 add: ok
```
3. Check the deployed application in BIG-IP, confirm it follows the change in NACOS server.
4. Run script to deregister some instance

```
$ ./deregister_instance.sh 10.1.10.40
10.1.10.40
endPoint 10.1.10.40 add: ok

```
5. Check the deployed application in BIG-IP, confirm it follows the change in NACOS server.