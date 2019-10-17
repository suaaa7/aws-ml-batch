package slack

import (
	"fmt"
	"os"
	"testing"
)

func TestMain(m *testing.M) {
	println("Before Test...")

	code := m.Run()

	println("After Test...")
	os.Exit(code)
}

func TestSend(t *testing.T) {
	webhookURL := os.Getenv("WEBHOOK_URL")
	slackURL := fmt.Sprintf("https://hooks.slack.com/services/%s", webhookURL)
	sl := New(slackURL, "", "Test", "", "", "")

	statusCode, err := sl.Send("Test")
	if webhookURL == "" || statusCode != 200 || err != nil {
		t.Errorf("WebhookURL: %s", webhookURL)
		t.Errorf("StatusCode: %d", statusCode)
		t.Fatalf("Error failed to Send: %v", err)
	}
}
