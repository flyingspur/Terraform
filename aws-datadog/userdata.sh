#!/bin/bash
yum -y update
yum -y install httpd
mkdir -p /var/www/html
echo "Hello, from CloudApp webserver - `hostname`" | tee -a  > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
