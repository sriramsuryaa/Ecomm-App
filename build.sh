#!/usr/bin/env bash
set -euo pipefail

# docker build -t ${env.REPO}:${env.IMAGE_TAG} .
# echo \$DHUB_PASS | docker login -u \$DHUB_USER --password-stdin
# docker push ${env.REPO}:${env.IMAGE_TAG}

docker build -t $REPO:$IMAGE_TAG .
docker tag $REPO:$IMAGE_TAG $REPO:$IMAGE_TAG
docker push $REPO:$IMAGE_TAG