// Purpose: Observe FQuat4f scalar divide, both value-returning and in place.
// AS-facing API: FQuat4f Result = Quat / Scale; Quat /= Scale;
// Inputs: (0,0,0,2) divided by 2.0, and a saved original for independence.
// Expected observations: / 2 returns W=1 without mutating the source. /= 2
// mutates W to 1.
// Boundary/ownership: / returns a new quaternion. /= mutates Quat. Scale
// must be non-zero.

namespace TS_FQuat4f_ConstructionAndAssignment_02
{
	bool Observe_Assignment_Nominal()
	{
		FQuat4f Quat(0.0, 0.0, 0.0, 2.0);
		FQuat4f Original = Quat;
		FQuat4f Result = Quat / 2.0;
		return Result.W == 1.0 && Original.W == 2.0 && Quat.W == 2.0;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FQuat4f Quat(0.0, 0.0, 0.0, 2.0);
		Quat /= 2.0;
		return Quat.W == 1.0 && Quat.X == 0.0;
	}
}
