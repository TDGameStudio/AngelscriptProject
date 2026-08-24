// Purpose: Observe static sphere and box intersection tests with tolerance.
// The bool return is the runner-readable oracle.
// AS-facing API: SpheresIntersect; BoxesIntersect.
// Inputs: Overlapping pair at 0 and 1 with radius 1, disjoint pair at 0 and
// 10, default KINDA_SMALL_NUMBER tolerance.
// Expected observations: Nearby spheres/boxes intersect. Distant pair does
// not. Tolerance argument is consumed.
// Boundary/ownership: Static tests do not mutate either bounds.

namespace TS_FBoxSphereBounds_NamespaceAndGlobalFunctions_01
{
	bool Observe_SpheresIntersect_Nominal()
	{
		FBoxSphereBounds A(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
		FBoxSphereBounds B(FVector(1, 0, 0), FVector(1, 1, 1), 1.0);
		FBoxSphereBounds Far(FVector(10, 0, 0), FVector(1, 1, 1), 1.0);
		return FBoxSphereBounds::SpheresIntersect(A, B) && !FBoxSphereBounds::SpheresIntersect(A, Far, KINDA_SMALL_NUMBER);
	}

	bool Observe_BoxesIntersect_Nominal()
	{
		FBoxSphereBounds A(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
		FBoxSphereBounds B(FVector(1, 0, 0), FVector(1, 1, 1), 1.0);
		FBoxSphereBounds Far(FVector(10, 0, 0), FVector(1, 1, 1), 1.0);
		return FBoxSphereBounds::BoxesIntersect(A, B) && !FBoxSphereBounds::BoxesIntersect(A, Far);
	}
}
