#!/bin/bash
docker stop webtop
rm -rf /opt/webtop/config
docker rm webtop
mkdir -p /opt/webtop/config
cd /opt/webtop && docker-compose up -d