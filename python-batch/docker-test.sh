#!/bin/sh

docker build \
    -t test \
    --build-arg BUCKET_NAME=Undefined \
    --build-arg WEBHOOK_URL=${WEBHOOK_URL} --no-cache .
sleep 10
docker run -it --rm test
sleep 10
docker rmi test
