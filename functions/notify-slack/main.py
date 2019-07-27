import boto3
import datetime
import json
import requests
from argparse import ArgumentParser

def get_option():
    argparser = ArgumentParser()
    argparser.add_argument("-whu", "--webhook_url", type=str,
                           default="Undefined", help="Webhook URL")
    argparser.add_argument("-bn", "--bucket_name", type=str,
                           default="Undefined", help="Bucket Name")

    return argparser.parse_args()

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

if __name__ == "__main__" :
    args = get_option()

    if args.bucket_name != "Undefined":
        put_json_to_s3(args.bucket_name)

    text = "batch finished."
    if args.webhook_url != "Undefined":
        post_to_slack(args.webhook_url, text)
