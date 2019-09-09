#!/bin/sh

apex infra apply -target=module.lambda_role -auto-approve
sleep 5
apex deploy \
  --set WEBHOOK_URL=$WEBHOOK_URL \
  --set BUCKET_NAME=$BUCKET_NAME notify-slack
apex deploy \
  --set WEBHOOK_URL=$WEBHOOK_URL \
  --set BUCKET_NAME=$BUCKET_NAME check-result
sleep 5
apex infra apply -auto-approve
