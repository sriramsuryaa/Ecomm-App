#!/usr/bin/env bash
set -euo pipefail

cd /home/ubuntu/deploy/

docker-compose pull
docker-compose down
docker-compose up -d
docker-compose ps