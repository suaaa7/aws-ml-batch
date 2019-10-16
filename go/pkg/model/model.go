package model

import (
	"bytes"
	"encoding/json"
)

// Metadata has ModelPath
type Metadata struct {
	ModelPath string `json:"modelpath"`
}

// ToBuffer return bytes.Buffer
func (mm Metadata) ToBuffer() bytes.Buffer {
	var buf bytes.Buffer
	b, _ := json.Marshal(mm)
	buf.Write(b)

	return buf
}
