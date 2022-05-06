#Autodiscover instances of Nacos by Nginx Plus
Use Nginx Plus to autodiscover the instances of Nacos and put the IP and port of the instance to nginx.conf

##Prerequisite
Nginx Plus instance
Nacos Server

##Demo

1. Download the package and extract to the Server of Nginx Plus. Please note that Nginx Plus, Nacos Server and the package are all in the same VM in this demo

2. Configure the nacos-nginx-template-0.6.1/conf/config.toml.example as below

```
nginx_cmd = "/usr/sbin/nginx"
nacos_addr = "192.168.5.33:8848"
reload_interval = 1000

[discover_config1]
nginx_config = "/etc/nginx/nginx.conf"
nginx_upstream = "www"
nacos_service_name = "service1"
```

Parameter	Description	Example
nginx_cmd	nginx_cmd path	"/usr/sbin/nginx"
nacos_addr	nacos_mgmtIP:port	"172.16.0.100:8848,172.16.0.101:8848,172.16.0.102:8848"
reload_interval	how frequent to reload the nginx plus（by default 1000ms）	1000
nacos_service_name	servcie name	"com.nacos.service.impl.NacosService"
nginx_config	config path	"/etc/nginx/nginx.conf"
nginx_upstream	upstream name	"nacos-service"

3. sh nacos-nginx-template-0.6.1/bin/startup.sh

4. Use curl to create a service with IP:port and make this service as permanet.

`curl -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=service1&ip=192.168.5.31&port=80&ephemeral=true'

5. Check the upstream www1 via dashboard to see if the 192.168.5.31:80 is discovered automatically or not.
