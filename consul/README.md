# Demo to show F5 MSDA with Consul

这是一个基于NGINX Plus 官方Demo制作的MSDA演示环境，原版NGINX Plus with Consul API demo: [NGINX-Demos/consul-api-demo at master · nginxinc/NGINX-Demos · GitHub](https://github.com/nginxinc/NGINX-Demos/tree/master/consul-api-demo). 

## 环境准备

1. Clone repo，我们使用bigip_api这个环境，进入文件夹，本地环境需要预装好docker。

2. 输出环境变量`$ export HOST_IP=x.x.x.x`，这个变量会被`docker-compose.yml`文件使用。

3. 拉起Consul环境 ：
   
   ```bash
   $ docker-compose up -d
   ```

4. 拉起后端http服务：
   
   ```bash
   $ docker-compose -f create-http-service.yml up -d
   ```

5. 检查环境，使用docker ps命令应该能看到以下3个容器在运行：
   
   ```bash
   [root@ngplusdocker ~/MSDA_consul/bigip_api]# docker ps --format "table  {{.Names}}  {{.Image}}  {{.Ports}}"
   NAMES  IMAGE  PORTS
   bigipapi_http_1  nginxdemos/hello:latest  0.0.0.0:32768->80/tcp, :::32768->80/tcp
   registrator  gliderlabs/registrator:latest  
   consul  progrium/consul:latest  53/tcp, 0.0.0.0:8300->8300/tcp, :::8300->8300/tcp, 0.0.0.0:8400->8400/tcp, :::8400->8400/tcp, 8301-8302/ tcp, 0.0.0.0:8500->8500/tcp, :::8500->8500/tcp, 8301-8302/udp, 0.0.0.0:8600->53/udp, :::8600->53/udp
   ```

6. 接下来我们验证MSDA的效果

## 使用GUI配置

1. 首先安装msda-consul的iApp rpm包，这里不再赘述

2. 创建一个Application Services : Applications LX

3. 输入名字，Template选择msdaconsul，点击Save

4. 点击进入刚才创建的服务，输入必要参数
   
   - consul endpoints: Consul服务的地址和端口，地址改成docker所在主机的ip，端口保留8500
   - Service Name保留http
   - 输入Pool的名字、LB算法、健康检查方法

5. 点击Deploy

6. 观察Pool的建立情况，同时可以通过http://ip:8500 打开Consul管理页面查看http服务的信息，对照pool中的member，这里的ip是docker容器网络的内部ip，端口是对外映射的端口，实际访问是不通的，不需要管它，只要看到consul中http服务的节点数量和ip端口和bigip pool中一致就行

7. 通过以下命令调整http服务的节点数量：
   
   ```bash
   $ docker-compose -f create-http-service.yml scale http=5
   $ docker-compose -f create-http-service.yml scale http=3
   ```
   
   8. 观察pool member和Consul的变化，所有的变化的应该能正确反映到pool中

## 使用API配置

1. iApp的API Endpoint是/mgmt/shared/iapp/blocks，首先使用GET方法获取blocks，在items中有一个state为TEMPLATE，name为msdaconsul的就是我们导入的iApp模板，复制它的selfLink，大概是这样的"https://localhost/mgmt/shared/iapp/blocks/53b47d4e-5c7c-3f42-93a3-fc34626f15be"

2. 对/mgmt/shared/iapp/blocks使用POST方法，创建一个新的App，Payload使用下面的模板，将其中的name、consul endpoints等参数替换，本例中这些参数和GUI上的一样，除了健康检查改成了http：
   
   ```json
   {
     "name": "web_api",
     "inputProperties": [
       {
         "id": "consulEndpoint",
         "type": "STRING",
         "value": "http://10.1.10.227:8500",
         "metaData": {
           "description": "consul endpoint list",
           "displayName": "consul endpoints",
           "isRequired": true
         }
       },
       {
          "id": "consulToken",
          "type": "STRING",
          "value": "",
          "metaData": {
              "description": "Access token for consul resource",
              "displayName": "X-Consul-Token",
              "isRequired": false
          }
       },
       {
          "id": "nameSpace",
          "type": "STRING",
          "value": "",
          "metaData": {
              "description": "Namespace for consul enterprise",
              "displayName": "Namespace",
              "isRequired": false
          }
       },
       {
         "id": "serviceName",
         "type": "STRING",
         "value": "http",
         "metaData": {
           "description": "Service name to be exposed",
           "displayName": "Service Name in registry",
           "isRequired": true
         }
       },
       {
         "id": "poolName",
         "type": "STRING",
         "value": "/Common/consulSamplePool_api",
         "metaData": {
           "description": "Pool Name to be created",
           "displayName": "BIG-IP Pool Name",
           "isRequired": true
         }
       },
       {
         "id": "poolType",
         "type": "STRING",
         "value": "round-robin",
         "metaData": {
           "description": "load-balancing-mode",
           "displayName": "Load Balancing Mode",
           "isRequired": true,
           "uiType": "dropdown",
           "uiHints": {
             "list": {
               "dataList": [
                 "round-robin",
                 "least-connections-member",
                 "least-connections-node"
               ]
             }
           }
         }
       },
       {
         "id": "healthMonitor",
         "type": "STRING",
         "value": "http",
         "metaData": {
           "description": "Health Monitor",
           "displayName": "Health Monitor",
           "isRequired": true,
           "uiType": "dropdown",
           "uiHints": {
             "list": {
               "dataList": [
                 "tcp",
                 "udp",
                 "http",
                 "none"
               ]
             }
           }
         }
       }
     ],
     "dataProperties": [
       {
         "id": "pollInterval",
         "type": "NUMBER",
         "value": 30,
         "metaData": {
           "description": "Interval of polling from BIG-IP to registry, 30s by default.",
           "displayName": "Polling Invertal",
           "isRequired": false
         }
       }
     ],
     "configurationProcessorReference": {
       "link": "https://localhost/mgmt/shared/iapp/processors/msdaconsulConfig"
     },
     "auditProcessorReference": {
       "link": "https://localhost/mgmt/shared/iapp/processors/msdaconsulEnforceConfiguredAudit"
     },
     "audit": {
       "intervalSeconds": 60,
       "policy": "ENFORCE_CONFIGURED"
     },
     "configProcessorTimeoutSeconds": 30,
     "statsProcessorTimeoutSeconds": 15,
     "configProcessorAffinity": {
       "processorPolicy": "LOAD_BALANCED",
       "affinityProcessorReference": {
         "link": "https://localhost/mgmt/shared/iapp/processors/affinity/load-balanced"
       }
     },
     "state": "BINDING",
     "baseReference": {
                   "link": "https://localhost/mgmt/shared/iapp/blocks/53b47d4e-5c7c-3f42-93a3-fc34626f15be"
     }
   }
   ```

3. 提交POST后，应该能在GUI上看到新建的App和Pool
