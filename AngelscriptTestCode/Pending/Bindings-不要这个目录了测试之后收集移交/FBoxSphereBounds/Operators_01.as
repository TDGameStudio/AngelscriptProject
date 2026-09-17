/**
 * @version v1
 * @summary Observe FBoxSphereBounds equality of origin, extent, and radius.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBoxSphereBounds equality of origin, extent, and radius.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Identical (0, extent 1, radius 1) bounds, a different origin, and
// Zero origin with zero radius.
// Expected observations: Identical copies compare true. Different origin
// compares false. Equality does not mutate operands.
// Boundary/ownership: Comparison is exact on all stored fields.

namespace TS_FBoxSphereBounds_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FBoxSphereBounds Left(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
		FBoxSphereBounds Right(FVector::ZeroVector, FVector(1, 1, 1), 1.0);
		FBoxSphereBounds Different(FVector(1, 0, 0), FVector(1, 1, 1), 1.0);
		return Left == Right && !(Left == Different);
	}
}
/** @end */
