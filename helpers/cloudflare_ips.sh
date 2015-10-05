#!/bin/bash
# Terminate if not run as root
if (( EUID != 0 )); then
    echo "RUN THIS SCRIPT AS ROOT." 1>&2
    exit 1
fi

CLOUDFLARE_IP_RANGES_FILE_PATH="/tmp/cloud_flare.conf"
NGINX_FILE_PATH="/etc/nginx/conf.d/"
WWW_GROUP="www-data"
WWW_USER="vagrant"

sudo wget -q -N https://www.cloudflare.com/ips-v4 -O /var/tmp/cloudflare-ips-v4 --no-check-certificate
sudo wget -q -N https://www.cloudflare.com/ips-v6 -O /var/tmp/cloudflare-ips-v6 --no-check-certificate

sudo echo "# CloudFlare IP Ranges" > $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo echo "# Generated at $(date) by $0" >> $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo echo "" >> $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo awk '{ print "set_real_ip_from " $0 ";" }' /var/tmp/cloudflare-ips-v4 >> $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo awk '{ print "set_real_ip_from " $0 ";" }' /var/tmp/cloudflare-ips-v6 >> $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo echo "" >> $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo echo "set_real_ip_from 127.0.0.1;" >> $CLOUDFLARE_IP_RANGES_FILE_PATH
sudo echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_IP_RANGES_FILE_PATH

sudo chown $WWW_USER:$WWW_GROUP $CLOUDFLARE_IP_RANGES_FILE_PATH

sudo rm -rf /var/tmp/cloudflare-ips-v4
sudo rm -rf /var/tmp/cloudflare-ips-v6

sudo mv $CLOUDFLARE_IP_RANGES_FILE_PATH $NGINX_FILE_PATH
