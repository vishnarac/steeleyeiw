#!/bin/bash

yum update -y
yum install haproxy -y

cat << EOF > /etc/haproxy/haproxy.cfg

global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
defaults
   log global
   mode http
   option httplog
   option dontlognull
   timeout connect 5000
   timeout client 50000
   timeout server 50000
frontend  main
   bind *:80
   stats uri /haproxy?stats
   default_backend http_back
backend http_back
    balance  roundrobin
#server  app1 ec2-13-233-198-175.ap-south-1.compute.amazonaws.com:8484 check
#server  app2 ec2-13-126-107-113.ap-south-1.compute.amazonaws.com:8484 check

EOF

sleep 5
echo "server  app1 $(head -n1 /tmp/public_dns_list.txt):8484 check" >> /etc/haproxy/haproxy.cfg
echo "server  app2 $(tail -n1 /tmp/public_dns_list.txt):8484 check" >> /etc/haproxy/haproxy.cfg
service haproxy restart

