package distance

import "math"

func EuclideanGeneric(a, b []float32) float64 {
	var sum float32
	for i := range a {
		diff := a[i] - b[i]
		sum += diff * diff
	}

	return math.Sqrt(float64(sum))
}
