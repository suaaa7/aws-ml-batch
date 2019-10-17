package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/suaaa7/aws-ml-batch/go/pkg/slack"
)

// MyEvent has Text
type MyEvent struct {
	Text string
}

// HandleLambdaEvent returns error
func HandleLambdaEvent(ctx context.Context, event MyEvent) error {
	slackURL := fmt.Sprintf(
		"https://hooks.slack.com/services/%s", os.Getenv("WEBHOOK_URL"))
	sl := slack.New(slackURL, "", "AWS Lambda", "", "", "")

	if _, err := sl.Send(event.Text); err != nil {
		return err
	}

	return nil
}

func main() {
	lambda.Start(HandleLambdaEvent)
}
