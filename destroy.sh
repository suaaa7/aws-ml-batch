#!/bin/sh

apex delete -f
sleep 5
apex infra destroy -target=module.cloudwatch -auto-approve
sleep 5
apex infra destroy -auto-approve
