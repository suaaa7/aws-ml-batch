package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/suaaa7/aws-ml-batch/go/pkg/model"
	mys3 "github.com/suaaa7/aws-ml-batch/go/pkg/s3"
	"github.com/suaaa7/aws-ml-batch/go/pkg/slack"
)

const modelJsonkey = "model.json"

// MyEvent has Text and ModelPath
type MyEvent struct {
	Text      string
	ModelPath string
}

// MyResponse has Result
type MyResponse struct {
	Result string
}

// HandleLambdaEvent returns error
func HandleLambdaEvent(ctx context.Context, event MyEvent) (MyResponse, error) {
	slackURL := fmt.Sprintf(
		"https://hooks.slack.com/services/%s", os.Getenv("WEBHOOK_URL"))
	sl := slack.New(slackURL, "", "AWS Lambda", "", "", "")
	bucket := os.Getenv("BUCKET_NAME")
	modelPath := event.ModelPath

	// CheckKey
	result := mys3.CheckKey(bucket, modelPath)
	var text string
	if result != nil {
		text = "Failed"
	} else {
		text = "Successed"
		// Uplaod
		mm := model.Metadata{ModelPath: modelPath}
		if err := mys3.Upload(mm.ToBuffer(), bucket, modelJsonkey); err != nil {
			return MyResponse{Result: ""}, err
		}
	}

	if _, err := sl.Send(text); err != nil {
		return MyResponse{Result: ""}, err
	}

	return MyResponse{Result: text}, nil
}

func main() {
	lambda.Start(HandleLambdaEvent)
}
