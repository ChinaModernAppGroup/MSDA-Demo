const Eureka = require('eureka-js-client').Eureka;
const eurekaServer = '10.1.10.40';

const eureka = new Eureka({
    instance: {
        app: 'msda-demo-service',
        hostName: 'centos41',
        ipAddr: '10.1.10.41',
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

var timeout = 120 * 1000;
setTimeout(function(){
    console.log('timed out!');
    eureka.stop(function(error){
        console.log(error || 'complete');
    });
},timeout);
