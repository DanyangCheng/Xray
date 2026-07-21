#!/bin/sh

mkdir -p /etc/xray
cp /config.json /etc/xray/config.json
cp /url.txt /etc/xray/url.txt
xray --config /etc/xray/config.json
