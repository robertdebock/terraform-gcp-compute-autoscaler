#!/bin/sh

apt-get -y update
apt-get -y install apache2
systemctl enable --now apache2
echo 'Hello world!' > /var/www/html/index.html
