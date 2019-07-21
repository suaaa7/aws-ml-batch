#!/bin/sh

docker build \
    -t ${AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} \
    --build-arg WEBHOOK_URL=${WEBHOOK_URL} \
    --build-arg BUCKET_NAME=${BUCKET_NAME} --no-cache .
