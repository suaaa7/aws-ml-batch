package slack

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"
)

// Slack has Url and Params
type Slack struct {
	url    string
	params params
}

// params has 5 values
type params struct {
	Text      string `json:"text"`
	Username  string `json:"username"`
	IconEmoji string `json:"icon_emoji"`
	IconURL   string `json:"icon_url"`
	Channel   string `json:"channel"`
}

func getJst() string {
	const myFormat = "2006/01/02 15:04:05"

	jst, _ := time.LoadLocation("Asia/Tokyo")
	nowTime := time.Now().In(jst).Format(myFormat)

	return nowTime
}

// New returns *slack
func New(url, text, username, iconEmoji, iconURL, channel string) *Slack {
	timeAndText := fmt.Sprintf("[%s]: %s", getJst(), text)
	p := params{
		Text:      timeAndText,
		Username:  username,
		IconEmoji: iconEmoji,
		IconURL:   iconURL,
		Channel:   channel,
	}

	return &Slack{url: url, params: p}
}

// Send returns error
func (s *Slack) Send(text string) (int, error) {
	s.params.Text = fmt.Sprintf("[%s]: %s", getJst(), text)

	params, err := json.Marshal(s.params)
	if err != nil {
		return 0, err
	}

	resp, err := http.PostForm(
		s.url,
		url.Values{"payload": {string(params)}},
	)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	return resp.StatusCode, nil
}
