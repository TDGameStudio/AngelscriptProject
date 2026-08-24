// Purpose: Observe exact FQuat component equality.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Two Identity copies, Identity vs (0,0,0,2), and Identity vs yaw 90.
// Expected observations: Identity copies compare true. A doubled W is false.
// Yaw 90 is false versus Identity.
// Boundary/ownership: == is exact component equality, unlike Equals with
// tolerance. The operands are not mutated.

namespace TS_FQuat_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FQuat Left = FQuat::Identity;
		FQuat Right = FQuat::Identity;
		FQuat Doubled(0.0, 0.0, 0.0, 2.0);
		FQuat Yaw(FRotator(0, 90, 0));
		return Left == Right && !(Left == Doubled) && !(Left == Yaw);
	}
}
