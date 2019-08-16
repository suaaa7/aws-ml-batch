import boto3
import datetime
import json
import os
import requests

def get_option_for_lambda():
    bucket_name = os.environ["BUCKET_NAME"]
    webhook_url = os.environ["WEBHOOK_URL"]
 
    return bucket_name, webhook_url

def put_json_to_s3(bucket_name):
    s3 = boto3.resource("s3")
    bucket = s3.Bucket(bucket_name)

    filename = "test_{0:%Y%m%d-%H%M}.json"
    pred_result = {
        "modelname": "base_model", 
        "accracy": 0.90
    }
    json_str = json.dumps(pred_result)

    now = datetime.datetime.now()
    bucket.put_object(
        ACL="private",
        Body=json_str,
        Key=filename.format(now),
        ContentType="text/json"
    )

def post_to_slack(whu, text):
    SLACK_URL = "https://hooks.slack.com/services/{}"

    json_data = {
        "text": text,
    }

    requests.post(SLACK_URL.format(whu), json.dumps(json_data))

def lambda_handler(event, context):
    bucket_name, webhook_url = get_option_for_lambda()

    put_json_to_s3(bucket_name)

    text = "batch finished."
    post_to_slack(webhook_url, text)
