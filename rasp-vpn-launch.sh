#!/bin/bash


source /home/lg/.rasp-vpn.env

logger "Connect to $RASP_ENDPOINT"

echo $COOKIE | /usr/sbin/openconnect \
    --protocol=gp \
    --useragent="PAN GlobalProtect" \
    --user=$RASP_USER \
    --passwd-on-stdin \
    --os=linux-64 \
    --usergroup=portal:prelogin-cookie \
    --csd-wrapper=$HIDREPORTER \
    --pid-file=/run/rasp-vpn.pid \
    $RASP_ENDPOINT
