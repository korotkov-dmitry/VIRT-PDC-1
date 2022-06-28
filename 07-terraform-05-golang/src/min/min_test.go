package main

import (
	"fmt"
	"testing"
)

func TestMin(t *testing.T) {
	var s int
	s = Min([]int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17})

	fmt.Println(s)

	if s == 0 {
		t.Error("Test", s)
	}
}
