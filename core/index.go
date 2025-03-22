package core

// Index represents a generic, production-grade ANN index.
type Index interface {

	// Add inserts a vector with a given id into the index.
	Add(id int, vector []float32) error

	// Delete removes the vector with the given id from the index.
	Delete(id int) error

	// Update modifies the vector associated with the given id.
	Update(id int, vector []float32) error

	// Search returns the ids and distances of the k nearest neighbors for a query vector.
	Search(query []float32, k int, distance DistanceFunc) ([]Neighbor, error)

	// RangeSearch returns all neighbor ids within the specified radius.
	RangeSearch(query []float32, radius float64, distance DistanceFunc) ([]int, error)

	// Stats returns metadata about the index, such as count and dimensionality.
	Stats() IndexStats

	// Save persists the index state to the specified file.
	Save(path string) error

	// Load initializes the index from a previously saved state.
	Load(path string) error
}

// DistanceFunc computes the distance between two vectors.
type DistanceFunc func(a, b []float32) float64

// Neighbor holds a neighbor's id and its computed distance.
type Neighbor struct {
	ID       int
	Distance float64
}

// IndexStats contains metadata about the index.
type IndexStats struct {
	Count     int // total number of indexed vectors
	Dimension int // dimensionality of vectors
	Size      int // size of the index in bytes
}
