# Setup Nacos server for testing

Follow up the offical doc to setup the nacos server in docker environment.

If you already have a nacos server running in you lab, you can skip this step.

[nacos-docker](https://nacos.io/zh-cn/docs/quick-start-docker.html)

## Option 1: Quick Start for Nacos Docker, setup a standalone instance for nacos
### Steps

Run the following command：

Clone project

```
git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
```

#### Advanced Usage

* Tips: You can change the version of the Nacos image in the compose file from the following configuration.
  `example/.env`

```dotenv
NACOS_VERSION=v2.0.4
NACOS_AUTH_ENABLE=true
```

Stand-alone Derby

`docker-compose -f example/standalone-derby.yaml up`

If you want to enable authentication, please add environment var in the yaml file, for example:

```
ubuntu@k8snode1:~/nacos-docker/example$ cat standalone-derby.yaml 
version: "2"
services:
  nacos:
    image: nacos/nacos-server:${NACOS_VERSION}
    container_name: nacos-standalone
    environment:
      - PREFER_HOST_MODE=hostname
      - MODE=standalone
      - NACOS_AUTH_ENABLE=true
    volumes:
      - ./standalone-logs/:/home/nacos/logs
    ports:
      - "8848:8848"
      - "9848:9848"
  prometheus:
    container_name: prometheus
    image: prom/prometheus:latest
    volumes:
      - ./prometheus/prometheus-standalone.yaml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    depends_on:
      - nacos
    restart: on-failure
  grafana:
    container_name: grafana
    image: grafana/grafana:latest
    ports:
      - 3000:3000
    restart: on-failure
ubuntu@k8snode1:~/nacos-docker/example$ 

```

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

## Option2: Quickstart for nacos-k8s, setup a nacos cluster for demo.
### Quick Start
	• Clone Project
git clone https://github.com/nacos-group/nacos-k8s.git
	• Simple Start
If you want to start Nacos without NFS, but emptyDirs will possibly result in a loss of data. as follows:
```
cd nacos-k8s
chmod +x quick-startup.sh
./quick-startup.sh

ubuntu@k8smaster:~/nacos-k8s$ 
ubuntu@k8smaster:~/nacos-k8s$ for i in 0 1 2; do echo nacos-$i; kubectl exec nacos-$i cat conf/cluster.conf; done
nacos-0
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
#2022-09-21T14:52:38.056
nacos-0.nacos-headless.default.svc.cluster.local:8848
nacos-1.nacos-headless.default.svc.cluster.local:8848
nacos-2.nacos-headless.default.svc.cluster.local:8848
nacos-1
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
#2022-09-21T14:52:37.639
nacos-0.nacos-headless.default.svc.cluster.local:8848
nacos-1.nacos-headless.default.svc.cluster.local:8848
nacos-2.nacos-headless.default.svc.cluster.local:8848
nacos-2
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
#2022-09-21T14:52:38.743
nacos-0.nacos-headless.default.svc.cluster.local:8848
nacos-1.nacos-headless.default.svc.cluster.local:8848
nacos-2.nacos-headless.default.svc.cluster.local:8848
ubuntu@k8smaster:~/nacos-k8s$ 

```

# Test MSDA-nacos for BIG-IP

## Import rpm package of MSDA-nacos into BIG-IP

Follow the instructions of [msda-nacos](https://github.com/ChinaModernAppGroup/msda-nacos), download the [mada-nacos rpm package](https://github.com/ChinaModernAppGroup/msda-nacos/releases) from the repo, and import it into BIG-IP.

## Setup Applications LX to watch NACOS server and configure BIG-IP pool

Goto iApps >> Application Services >> create a new iAppLX application.

For example:
 ![msda-nacos-demo4](./images/msda-nacos-demo4.png)

 ![msda-nacos-demo5](./images/msda-nacos-demo5.png)

Make sure both the `msda.nacos.com` and `msda.nacos.com:8080` are deployed.
![msda-nacos-demo deployed](./images/deploy.png)

## Start the demo

1. Export environment variable for NACOS server, for example:

```
ubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ cd MSDA-Demo/nacos/
ubuntu@k8smaster:~/MSDA-Demo/nacos$ 
ubuntu@k8smaster:~/MSDA-Demo/nacos$ ls -l
total 28
drwxrwxr-x 2 ubuntu ubuntu 4096 Sep 18 07:24 'Nacos autodiscover by Nginx Plus'
-rw-rw-r-- 1 ubuntu ubuntu 1258 Sep 18 07:24  README.md
-rw-rw-r-- 1 ubuntu ubuntu  302 Sep 18 07:24  batch_deregister_instances.sh
-rw-rw-r-- 1 ubuntu ubuntu  313 Sep 18 07:24  batch_register_instances.sh
-rwxrwxr-x 1 ubuntu ubuntu  668 Sep 18 08:23  deregister_instance.sh
-rwxrwxr-x 1 ubuntu ubuntu  668 Sep 18 08:22  register_instance.sh
-rwxrwxr-x 1 ubuntu ubuntu  301 Sep 18 08:42  watchInstances.sh
ubuntu@k8smaster:~/MSDA-Demo/nacos$ 

```
Define NACOS_IP variable.

`export NACOS_IP=10.1.20.5`

If you are in the node running the NACOS server, and no need to export the `NACOS_IP` variable.

```bash

root@k8snode1:/# 
root@k8snode1:/# 
root@k8snode1:/# su ubuntu 
ubuntu@k8snode1:/$ 
ubuntu@k8snode1:/$ 
ubuntu@k8snode1:/$ cd 
ubuntu@k8snode1:~$ 
ubuntu@k8snode1:~$ 
ubuntu@k8snode1:~$ cd MSDA-Demo/
ubuntu@k8snode1:~/MSDA-Demo$ 
ubuntu@k8snode1:~/MSDA-Demo$ 
ubuntu@k8snode1:~/MSDA-Demo$ cd 
.git/           consul/         etcd/           etcdv3/         eureka/         k8s/            nacos/          zookeeper-demo/ 
ubuntu@k8snode1:~/MSDA-Demo$ cd nacos/
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ls -al 
total 40
drwxrwxr-x  3 ubuntu ubuntu 4096 Oct  6  2022  .
drwxrwxr-x 10 ubuntu ubuntu 4096 Oct  6  2022  ..
drwxrwxr-x  2 ubuntu ubuntu 4096 Oct  6  2022 'Nacos autodiscover by Nginx Plus'
-rw-rw-r--  1 ubuntu ubuntu 5988 Oct  6  2022  README.md
-rw-rw-r--  1 ubuntu ubuntu  302 Oct  6  2022  batch_deregister_instances.sh
-rw-rw-r--  1 ubuntu ubuntu  313 Oct  6  2022  batch_register_instances.sh
-rwxrwxr-x  1 ubuntu ubuntu  801 Oct  6  2022  deregister_instance.sh
-rwxrwxr-x  1 ubuntu ubuntu  808 Oct  6  2022  register_instance.sh
-rwxrwxr-x  1 ubuntu ubuntu  675 Oct  6  2022  watchInstances.sh
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ sudo docker ps 
CONTAINER ID   IMAGE                       COMMAND                  CREATED       STATUS             PORTS                                                                                  NAMES
fcbf0414022a   springcloud/eureka          "java -jar /app.jar …"   2 years ago   Up About an hour   0.0.0.0:8761->8761/tcp, :::8761->8761/tcp                                              objective_kare
f99f77cb217d   prom/prometheus:latest      "/bin/prometheus --c…"   2 years ago   Up About an hour   0.0.0.0:9090->9090/tcp, :::9090->9090/tcp                                              prometheus
93b4fd5f0162   nacos/nacos-server:v2.0.4   "bin/docker-startup.…"   2 years ago   Up About an hour   0.0.0.0:8848->8848/tcp, :::8848->8848/tcp, 0.0.0.0:9848->9848/tcp, :::9848->9848/tcp   nacos-standalone
9054f7a03fec   grafana/grafana:latest      "/run.sh"                2 years ago   Up About an hour   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp                                              grafana
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./watchInstances.sh 
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
      "instanceId": "10.1.10.40#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.41#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.42#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./watchInstances.sh ns-f5-msda-demo
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
Found namespaceId:ns-f5-msda-demo, will expand it to servicename
      "instanceId": "10.1.10.52#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.51#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.40#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.42#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.43#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.50#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 

```

1. Run register script to register some instances

```bash

$ ./register_instance.sh 10.1.10.40
10.1.10.40
endPoint 10.1.10.40 add: ok
$ ./register_instance.sh 10.1.10.41
10.1.10.41
endPoint 10.1.10.41 add: ok

ubuntu@k8smaster:~/MSDA-Demo/nacos$ 
ubuntu@k8smaster:~/MSDA-Demo/nacos$ ./watchInstances.sh 
      "instanceId": "10.1.10.40#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.41#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.42#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
ubuntu@k8smaster:~/MSDA-Demo/nacos$ 

ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./register_instance.sh 10.1.10.53 ns-f5-msda-demo
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
10.1.10.53
ns-f5-msda-demo
Found namespaceId:ns-f5-msda-demo, will expand it to servicename
endPoint 10.1.10.53 add: ok
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./watchInstances.sh ns-f5-msda-demo
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
Found namespaceId:ns-f5-msda-demo, will expand it to servicename
      "instanceId": "10.1.10.52#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.51#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.40#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.42#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.53#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.43#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.50#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 

```

3. Check the deployed application in BIG-IP, confirm it follows the change in NACOS server.

```bash
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# list ltm pool nacosSamplePool4
ltm pool nacosSamplePool4 {
    members {
        10.1.10.40:8080 {
            address 10.1.10.40
        }
        10.1.10.42:8080 {
            address 10.1.10.42
        }
        10.1.10.43:8080 {
            address 10.1.10.43
        }
        10.1.10.50:8080 {
            address 10.1.10.50
        }
        10.1.10.51:8080 {
            address 10.1.10.51
        }
        10.1.10.52:8080 {
            address 10.1.10.52
        }
        10.1.10.53:8080 {
            address 10.1.10.53
        }
    }
}
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# list ltm pool nacosSamplePool5
ltm pool nacosSamplePool5 {
    members {
        10.1.10.40:8080 {
            address 10.1.10.40
        }
        10.1.10.41:8080 {
            address 10.1.10.41
        }
        10.1.10.42:8080 {
            address 10.1.10.42
        }
    }
}
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 

```

4. Run script to deregister some instance

```bash
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./deregister_instance.sh 10.1.10.40
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
10.1.10.40
endPoint 10.1.10.40 add: ok
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./watchInstances.sh 
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
      "instanceId": "10.1.10.41#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.42#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./deregister_instance.sh 10.1.10.40 ns-f5-msda-demo
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
10.1.10.40
Found namespaceId:ns-f5-msda-demo, will expand it to servicename
endPoint 10.1.10.40 add: ok
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ ./watchInstances.sh ns-f5-msda-demo
NACOS_IP not set. Setting it to 127.0.0.1 (IP address assigned in the Vagrantfile)
Found namespaceId:ns-f5-msda-demo, will expand it to servicename
      "instanceId": "10.1.10.52#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.51#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.42#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.53#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.43#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
      "instanceId": "10.1.10.50#8080#DEFAULT#DEFAULT_GROUP@@msda.nacos.com",
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 
ubuntu@k8snode1:~/MSDA-Demo/nacos$ 

```

5. Check the deployed application in BIG-IP, confirm it follows the change in NACOS server.

```bash
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# list ltm pool nacosSamplePool4
ltm pool nacosSamplePool4 {
    members {
        10.1.10.42:8080 {
            address 10.1.10.42
        }
        10.1.10.43:8080 {
            address 10.1.10.43
        }
        10.1.10.50:8080 {
            address 10.1.10.50
        }
        10.1.10.51:8080 {
            address 10.1.10.51
        }
        10.1.10.52:8080 {
            address 10.1.10.52
        }
        10.1.10.53:8080 {
            address 10.1.10.53
        }
    }
}
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# list ltm pool nacosSamplePool5
ltm pool nacosSamplePool5 {
    members {
        10.1.10.41:8080 {
            address 10.1.10.41
        }
        10.1.10.42:8080 {
            address 10.1.10.42
        }
    }
}
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 
root@(bigip1)(cfg-sync Standalone)(Active)(/Common)(tmos)# 

```
