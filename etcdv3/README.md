# Prepare the cert authentication for etcdv3

We are using embedded etcd in Kubernetes for a quick demo.
Find the certificates for etcd.

```
ubuntu@k8smaster:~$ ls /etc/kubernetes/pki/etcd/ -l
total 32
-rw-r--r-- 1 root root 1086 Sep 17 12:48 ca.crt
-rw------- 1 root root 1675 Sep 17 12:48 ca.key
-rw-r--r-- 1 root root 1159 Sep 17 12:48 healthcheck-client.crt
-rw------- 1 root root 1679 Sep 17 12:48 healthcheck-client.key
-rw-r--r-- 1 root root 1200 Sep 17 12:48 peer.crt
-rw------- 1 root root 1679 Sep 17 12:48 peer.key
-rw-r--r-- 1 root root 1200 Sep 17 12:48 server.crt
-rw------- 1 root root 1675 Sep 17 12:48 server.key
ubuntu@k8smaster:~$ 

```

Convert cert and key into base64 encoding.

```
ubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ cat /etc/kubernetes/pki/etcd/ca.crt | base64 -w 0 > etcd-ca-b64
ubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ cat etcd-ca-b64 
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM5VENDQWQyZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFTTVJBd0RnWURWUVFERXdkbGRHTmsKTFdOaE1CNFhEVEl5TURreE56RXlORGcwTkZvWERUTXlNRGt4TkRFeU5EZzBORm93RWpFUU1BNEdBMVVFQXhNSApaWFJqWkMxallUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUozazF3NmFvU2lUCnRldXVDRyt2K0NMMkNRMVI1WjRpenhIMFREY0c5U0RMTTNsNVlSNlZ1b3JzTnRnMm1LdXQwTzFsc25JYzFQSWIKaVhRdnhTNGtZbXBldEROdzVTd0UrT0xpV2hWcGROT3c3Qk9rN0w4L1VXd2xFcEFFSS9UR0ZpMHdzWW1lNjMzdQpLZlVOWk1zVDB1T1FHNm1RNzJvQnY1UDRYQWRRV20rNXFPVFovRzZ2VTY3ekp6QVVvOXh3NlNjYXNkN2pjRFl5CkdBTGVKQXFMbUxhWitFS3NSSjdGR2FsVlNvbCtpakw0eUpKcW54MUZEZ2dXSnhJZnB4R3R6QVN6V0I1WTYvZXQKL011TmxrWUN2ODJ2U2ZrVXkyNVpEWGhscWVSeHM0a0RzdDB0Q1U3TkZYTXFNZDZId0MwTWYvQUorM3FsSzZDYgpuV1c1NEZjRGY5VUNBd0VBQWFOV01GUXdEZ1lEVlIwUEFRSC9CQVFEQWdLa01BOEdBMVVkRXdFQi93UUZNQU1CCkFmOHdIUVlEVlIwT0JCWUVGTFA4bVNHMmtjcmhuRWJ0eGY5Mi8yRHZwZ3hBTUJJR0ExVWRFUVFMTUFtQ0IyVjAKWTJRdFkyRXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSHo4WS9TdGZ4MG5ySWw1SEtPSkVkdC9ScVdTUGlKMgo3V3F2d0xQOTU5RVFrZTBnREpwVzhKRE82YWhaK3RaNnVRclhSZXhqdVhGRmRNSmVMbzhNR0dqQUNvT2FaOFhMCm5MYlhnVVUzcVUzYkpIcjE3SXRqMDBNTHY5R3pRZUpieFBMK1E1dzdIVHFIUCs0eWR1dTJxMExPQVNCYmZGdlAKZ1ZBbHNrT0lqaU12SElTQzFBTTduRUUrdEZwOVdkeWRIekZtMko4YnpLRHNBaFVDdWtKaGQzNzBGdUJwZHBBSwpsVHFUdXBMemZVZW02VjI5aEIrYlQzak1PbU5hTGt6TFlib1k0eXRMQWZMTm1LMy9ETi9JYzRUTUtERW5PWWx2ClBqcHppMTUyNU1VNkFrdnc0SHA0UDBjZUR6OHFpQWxNMXpma21JS2thVkliZTdvM0VCNVREVG89Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0Kubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ cat /etc/kubernetes/pki/etcd/server.crt | base64 -w 0 > etcd-servercrt-b64
ubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ sudo cat /etc/kubernetes/pki/etcd/server.key | base64 -w 0 > etcd-serverkey-b64
ubuntu@k8smaster:~$ 
ubuntu@k8smaster:~$ ls -l
total 43600
-rw-rw-r-- 1 ubuntu ubuntu     1448 Sep 17 14:51 etcd-ca-b64
-rw-rw-r-- 1 ubuntu ubuntu     1600 Sep 17 14:52 etcd-servercrt-b64
-rw-rw-r-- 1 ubuntu ubuntu     2236 Sep 17 14:53 etcd-serverkey-b64
ubuntu@k8smaster:~$
```
# Deploy MSDA-k8s applications LX

Follow the instruction of MSDA-K8S to deploy a MDSA-etcdv3 application, use the base64 cert and key for authentication.
Define the servie name in the etcd service registry, for example, /msdademo/http.

# Add instances for the service

## Define the environment variables for etcdctl.

```
root@k8smaster:/# 
root@k8smaster:/# export ETCDCTL_API=3
root@k8smaster:/# export ETCDCTL_DIAL_TIMEOUT=3s
root@k8smaster:/# export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
root@k8smaster:/# export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
root@k8smaster:/# export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key
root@k8smaster:/# 

```
## Add instances for the service.

```
root@k8smaster:/# 
root@k8smaster:/# etcdctl put /msdademo/http "10.1.10.66:8080, 10.1.10.77:8080, 10.1.10.88:8080"
OK
root@k8smaster:/# 
root@k8smaster:/# 
root@k8smaster:/# etcdctl get /msdademo/http
/msdademo/http
10.1.10.66:8080, 10.1.10.77:8080, 10.1.10.99:8080
root@k8smaster:/# 

```
Check the pool member in big-ip, confirm it follows the change.

## Add more instance for the service, simulate the scale up.

```
root@k8smaster:/# 
root@k8smaster:/# etcdctl put /msdademo/http "10.1.10.66:8080, 10.1.10.77:8080, 10.1.10.99:8080"
OK
root@k8smaster:/# 
root@k8smaster:/# 
root@k8smaster:/# etcdctl get /msdademo/http
/msdademo/http
10.1.10.66:8080, 10.1.10.77:8080, 10.1.10.99:8080
root@k8smaster:/# 

```

Check the pool member in big-ip, confirm it follows the change.

## Update the serice, remove instance from the service

```
root@k8smaster:/# etcdctl put /msdademo/http "10.1.10.66:8080, 10.1.10.77:8080, 10.1.10.88:8080"
OK
root@k8smaster:/# 
root@k8smaster:/# 
root@k8smaster:/# 
root@k8smaster:/# etcdctl get /msdademo/http
/msdademo/http
10.1.10.66:8080, 10.1.10.77:8080, 10.1.10.88:8080
root@k8smaster:/# 

```
Check the pool member in big-ip, confirm it follows the change.

## Delete the service

```
oot@k8smaster:/# 
root@k8smaster:/# etcdctl del /msdademo/http
1
root@k8smaster:/# 
root@k8smaster:/# 
root@k8smaster:/# etcdctl get /msdademo/http
root@k8smaster:/# 
```
Check the pool member in big-ip, confirm it follows the change.

Finish the demo, undeploy the MSDA-etcdv3 applications LX.