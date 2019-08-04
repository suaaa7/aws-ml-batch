#!/bin/sh

apex delete -f
sleep 5
apex infra destroy -auto-approve
