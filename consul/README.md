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
