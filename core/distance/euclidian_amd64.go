//go:build amd64

package distance

import (
	"math"
	"unsafe"

	"golang.org/x/sys/cpu"
)

//go:noescape
func euclideanAVX2(aptr unsafe.Pointer, bptr unsafe.Pointer, l int, result unsafe.Pointer)

func Euclidean(a, b []float32) float64 {
	if cpu.X86.HasAVX2 {
		var result float64
		l := len(a) / 8
		if l > 0 {
			var partialResult [8]float32
			euclideanAVX2(
				unsafe.Pointer(&a[0]),
				unsafe.Pointer(&b[0]),
				l,
				unsafe.Pointer(&partialResult[0]),
			)

			for i := 0; i < 8; i++ {
				result += float64(partialResult[i])
			}
		}

		for i := l * 8; i < len(a); i++ {
			diff := float64(a[i] - b[i])
			result += diff * diff
		}
		return math.Sqrt(result)
	} else {
		return EuclideanGeneric(a, b)
	}
}
