//go:build !amd64

package distance

func Euclidean(a, b []float32) float64 {
	return EuclideanGeneric(a, b)
}
