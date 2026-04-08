#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:-react-ecommerce-app}"
TAG="${2:-dev}"

docker build -t "${IMAGE_NAME}:${TAG}" .
echo "Built image: ${IMAGE_NAME}:${TAG}"
