#!/usr/bin/env bash
set -euo pipefail

docker build -t $REPO:$IMAGE_TAG .
docker tag $REPO:$IMAGE_TAG $REPO:$IMAGE_TAG
docker push $REPO:$IMAGE_TAG