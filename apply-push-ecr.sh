#!/bin/sh

apex infra apply -target=module.ecr -auto-approve
sleep 10
docker push \
    ${AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
