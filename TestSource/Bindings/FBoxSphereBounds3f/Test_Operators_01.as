// Purpose: Observe FBoxSphereBounds3f field equality.
// The bool return is the runner-readable oracle.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Identical origin/extent/radius copies and a different origin.
// Expected observations: Copies compare true; different origin is false.
// Boundary/ownership: Equality is exact on stored float32 fields.

namespace TS_FBoxSphereBounds3f_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FBoxSphereBounds3f Left(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f Right(FVector3f::ZeroVector, FVector3f(1, 1, 1), 1.0);
		FBoxSphereBounds3f Different(FVector3f(1, 0, 0), FVector3f(1, 1, 1), 1.0);
		return (Left == Right) && !(Left == Different);
	}
}
