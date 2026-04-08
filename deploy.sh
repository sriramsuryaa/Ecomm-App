#!/bin/bash
set -e

cd /home/ubuntu/deploy/

docker-compose pull
docker-compose down
docker-compose up -d
docker-compose ps