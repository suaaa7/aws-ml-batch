#!/bin/sh

apex infra apply -target=module.lambda_role -auto-approve
sleep 10
apex deploy \
  --set WEBHOOK_URL=$WEBHOOK_URL \
  --set BUCKET_NAME=$BUCKET_NAME notify-slack
apex deploy \
  --set WEBHOOK_URL=$WEBHOOK_URL \
  --set BUCKET_NAME=$BUCKET_NAME check-result
sleep 10
apex infra apply -auto-approve
