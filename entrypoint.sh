#!/bin/sh

mkdir -p /etc/xray
if [ ! -f /etc/xray/config.json ]; then
    cp /config.json /etc/xray/config.json
fi
cp /url.txt /etc/xray/url.txt
xray --config /etc/xray/config.json
