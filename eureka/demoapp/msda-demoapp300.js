const Eureka = require('eureka-js-client').Eureka;
const eurekaServer = "127.0.0.1";

const eureka = new Eureka({
    instance: {
        //instanceId: 'msda-demo-service:centos42:10.1.10.42',
        app: 'msda-demo-service',
        hostName: 'centos42',
        ipAddr: '10.1.10.42',
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

var timeout = 300 * 1000;
setTimeout(function(){
    console.log('timed out!');
    eureka.stop(function(error){
        console.log(error || 'complete');
    });
},timeout);
