package main

func Min(x []int) int {

	s := 0
	for i := range x {

		if s > x[i] {
			s = x[i]
		} else {
			if i == 0 {
				s = x[i]
			}
		}
	}
	return s
}
