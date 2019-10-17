package model

import (
	"fmt"
	"testing"
)

func TestToBuffer(t *testing.T) {
	t.Run("ToBuffer", func(t *testing.T) {
		data := Metadata{ModelPath: "test.json"}
		buf := data.ToBuffer()
		if len(buf.Bytes()) == 0 {
			t.Fatalf("Error failed to MM.ToBuffer")
		}

		fmt.Println("Test MM.ToBuffer...")
	})
}
