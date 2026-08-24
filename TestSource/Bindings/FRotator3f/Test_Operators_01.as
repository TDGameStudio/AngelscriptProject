// Purpose: Observe exact FRotator3f equality.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Identical (10,20,30) copies, a different yaw, and ZeroRotator.
// Expected observations: Identical copies compare true. Different yaw compares
// false. Zero equals ZeroRotator.
// Boundary/ownership: == compares raw degree components exactly.

namespace TS_FRotator3f_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FRotator3f Left(10.0, 20.0, 30.0);
		FRotator3f Right(10.0, 20.0, 30.0);
		FRotator3f Different(10.0, 21.0, 30.0);
		FRotator3f Zero;
		return (Left == Right) && !(Left == Different) && (Zero == FRotator3f::ZeroRotator);
	}
}
