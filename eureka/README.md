# Prepare springCloud eureka server

`docker pull springcloud/eureka`

run eureka server as a docker container.

`docker run -p 8761:8761 springcloud/eureka -d`

check the container is running.

```
root@ubuntu:~/MSDA-Demo/eureka/demoapp# docker ps 
CONTAINER ID   IMAGE                COMMAND                CREATED        STATUS        PORTS                                       NAMES
b2758037afee   springcloud/eureka   "java -jar /app.jar"   23 hours ago   Up 12 hours   0.0.0.0:8761->8761/tcp, :::8761->8761/tcp   competent_kare
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp#
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# curl -s -X GET http://localhost:8761/eureka/apps
<applications>
  <versions__delta>1</versions__delta>
  <apps__hashcode></apps__hashcode>
</applications>root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 


```
You can also verify with web browser: http://localhost:8761/ .


# Prepare application with eureka client

make sure you have node.js installed.

```
root@ubuntu:~/MSDA-Demo/eureka/demoapp# node -v 
v16.13.1
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
```

Install eureka client module.

`npm install eureka-js-client --save`

```
oot@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# npm list
demoapp@ /root/MSDA-Demo/eureka/demoapp
└── eureka-js-client@4.5.0

root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
```
Create couple of applications use this template:

```
const Eureka = require('eureka-js-client').Eureka;
const eurekaServer = '10.1.10.40';

const eureka = new Eureka({
    instance: {
        app: 'msda-demo-service',
        hostName: 'centos40',
        ipAddr: '10.1.10.40',
        statusPageUrl: 'http://localhost:8080',
        port: {
            '$': 8080,
            '@enabled': 'true',
        },
        vipAddress: 'localhost',
        dataCenterInfo: {
            '@Class': 'com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo',
        name: 'MyOwn',
        }
    },
    eureka: {
        host: eurekaServer,
        port: 8761, /* Spring Cloud Eureka Registry */
        servicePath: '/eureka/apps/'
    }
});
eureka.logger.level('debug');
eureka.start(function(error){
    console.log(error || 'complete');
});

var timeout = 60 * 1000;
setTimeout(function(){
    console.log('timed out!');
    eureka.stop(function(error){
        console.log(error || 'complete');
    });
},timeout);

```

Make sure to change the IP address of eureka server into your server address.

# Start application client, you will see it registered into eureka server

`node mada-demoapp600.js &`
`node mada-demoapp300.js &`
`node mada-demoapp120.js &`

```
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# node msda-demoapp600.js &
[1] 84213
root@ubuntu:~/MSDA-Demo/eureka/demoapp# registered with eureka:  msda-demo-service/centos41
retrieved full registry successfully
complete

root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# node msda-demoapp300.js &
[2] 84260
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# registered with eureka:  msda-demo-service/centos42
retrieved full registry successfully
complete

root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# curl -s -X GET http://localhost:8761/eureka/apps
<applications>
  <versions__delta>1</versions__delta>
  <apps__hashcode></apps__hashcode>
</applications>
root@ubuntu:~/MSDA-Demo/eureka/demoapp# curl -s -X GET http://localhost:8761/eureka/apps/msda-demo-service
<application>
  <name>MSDA-DEMO-SERVICE</name>
  <instance>
    <hostName>centos41</hostName>
    <app>MSDA-DEMO-SERVICE</app>
    <ipAddr>10.1.10.41</ipAddr>
    <status>UP</status>
    <overriddenstatus>UNKNOWN</overriddenstatus>
    <port enabled="true">8080</port>
    <securePort enabled="false">7002</securePort>
    <countryId>1</countryId>
    <dataCenterInfo class="com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo">
      <name>MyOwn</name>
    </dataCenterInfo>
    <leaseInfo>
      <renewalIntervalInSecs>30</renewalIntervalInSecs>
      <durationInSecs>90</durationInSecs>
      <registrationTimestamp>1651761834240</registrationTimestamp>
      <lastRenewalTimestamp>1651761834240</lastRenewalTimestamp>
      <evictionTimestamp>0</evictionTimestamp>
      <serviceUpTimestamp>1651761834095</serviceUpTimestamp>
    </leaseInfo>
    <metadata class="java.util.Collections$EmptyMap"/>
    <statusPageUrl>http://localhost:8080</statusPageUrl>
    <vipAddress>localhost</vipAddress>
    <isCoordinatingDiscoveryServer>false</isCoordinatingDiscoveryServer>
    <lastUpdatedTimestamp>1651761834240</lastUpdatedTimestamp>
    <lastDirtyTimestamp>1651761834094</lastDirtyTimestamp>
    <actionType>ADDED</actionType>
  </instance>
  <instance>
    <hostName>centos42</hostName>
    <app>MSDA-DEMO-SERVICE</app>
    <ipAddr>10.1.10.42</ipAddr>
    <status>UP</status>
    <overriddenstatus>UNKNOWN</overriddenstatus>
    <port enabled="true">8080</port>
    <securePort enabled="false">7002</securePort>
    <countryId>1</countryId>
    <dataCenterInfo class="com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo">
      <name>MyOwn</name>
    </dataCenterInfo>
    <leaseInfo>
      <renewalIntervalInSecs>30</renewalIntervalInSecs>
      <durationInSecs>90</durationInSecs>
      <registrationTimestamp>1651761840742</registrationTimestamp>
      <lastRenewalTimestamp>1651761840742</lastRenewalTimestamp>
      <evictionTimestamp>0</evictionTimestamp>
      <serviceUpTimestamp>1651761840541</serviceUpTimestamp>
    </leaseInfo>
    <metadata class="java.util.Collections$EmptyMap"/>
    <statusPageUrl>http://localhost:8080</statusPageUrl>
    <vipAddress>localhost</vipAddress>
    <isCoordinatingDiscoveryServer>false</isCoordinatingDiscoveryServer>
    <lastUpdatedTimestamp>1651761840743</lastUpdatedTimestamp>
    <lastDirtyTimestamp>1651761840541</lastDirtyTimestamp>
    <actionType>ADDED</actionType>
  </instance>
</application>root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# 
root@ubuntu:~/MSDA-Demo/eureka/demoapp# eureka heartbeat success
retrieved full registry successfully
eureka heartbeat success
retrieved full registry successfully

```

# Follow up the instructions for MSDA-eureka to install the msda-eureka rpm package into a BIG-IP unit, and then try to deploy an application LX with the template.

# clean up the docker container after finish the demo

ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ 
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ docker ps 
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ docker ps -a 
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS                        PORTS     NAMES
ffab4a6c3194   springcloud/eureka   "java -jar /app.jar …"   29 minutes ago   Exited (130) 35 seconds ago             wonderful_heisenberg
7984174af653   hello-world          "/hello"                 3 days ago       Exited (0) 3 days ago                   interesting_albattani
0bc847ad5581   hello-world          "/hello"                 3 days ago       Exited (0) 3 days ago                   flamboyant_bhabha
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ docker rm ff
ff
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ 
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ 
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ docker ps -a 
CONTAINER ID   IMAGE         COMMAND    CREATED      STATUS                  PORTS     NAMES
7984174af653   hello-world   "/hello"   3 days ago   Exited (0) 3 days ago             interesting_albattani
0bc847ad5581   hello-world   "/hello"   3 days ago   Exited (0) 3 days ago             flamboyant_bhabha
ubuntu@k8smaster:~/MSDA-Demo/eureka/demoapp$ 