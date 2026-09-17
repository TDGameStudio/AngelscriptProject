/**
 * @version v1
 * @summary Observe static FBoxSphereBounds3f sphere/box intersection.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe static FBoxSphereBounds3f sphere/box intersection.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: SpheresIntersect; BoxesIntersect.
// Inputs: Nearby pair offset by 1, far pair offset by 10, float32 tolerance
// KINDA_SMALL_NUMBER.
// Expected observations: Nearby intersects; far does not.
// Boundary/ownership: Static tests do not mutate either operand.

namespace TS_FBoxSphereBounds3f_NamespaceAndGlobalFunctions_01
{
	bool Observe_SpheresIntersect_Nominal()
	{
		FBoxSphereBounds3f A(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f B(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f Far(FVector3f(10, 0, 0), FVector3f(1, 1, 1), 1.0);
		return FBoxSphereBounds3f::SpheresIntersect(A, B) && !FBoxSphereBounds3f::SpheresIntersect(A, Far, KINDA_SMALL_NUMBER);
	}

	bool Observe_BoxesIntersect_Nominal()
	{
		FBoxSphereBounds3f A(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f B(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f Far(FVector3f(10, 0, 0), FVector3f(1, 1, 1), 1.0);
		return FBoxSphereBounds3f::BoxesIntersect(A, B) && !FBoxSphereBounds3f::BoxesIntersect(A, Far);
	}
}
/** @end */
