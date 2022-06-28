package main

import (
	"fmt"
)

func main() {

	for i := 1; i < 101; i++ {

		var t = i % 3
		if t == 0 {
			fmt.Println(i)
		}
	}
}
