import datetime
import json
import os
import requests

def get_option_for_lambda():
    bucket_name = os.environ["BUCKET_NAME"]
    webhook_url = os.environ["WEBHOOK_URL"]
 
    return bucket_name, webhook_url

def post_to_slack(whu, text):
    SLACK_URL = "https://hooks.slack.com/services/{}"

    now = datetime.datetime.now()
    json_data = {
        "text": text,
        "time": "{0:%Y%m%d-%H%M}".format(now),
    }

    requests.post(SLACK_URL.format(whu), json.dumps(json_data))

def lambda_handler(event, context):
    bucket_name, webhook_url = get_option_for_lambda()

    text = event["text"]
    post_to_slack(webhook_url, text)

    return {
        "result": text
    }
