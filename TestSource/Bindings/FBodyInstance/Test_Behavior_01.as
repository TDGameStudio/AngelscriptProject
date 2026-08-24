// Purpose: Observe Weld and UnWeld between two FBodyInstance values.
// The bool return is the runner-readable oracle.
// AS-facing API: bool FBodyInstance.Weld(FBodyInstance& TheirBody, const FTransform& TheirTM);
// void FBodyInstance.UnWeld(FBodyInstance& TheirBI);
// Inputs: Two default FBodyInstance values, Identity TheirTM, an offset
// transform, and a second UnWeld after the first.
// Expected observations: Weld returns false on default instances without
// physics bodies. UnWeld is issued on the same pair after a failed weld.
// Boundary/ownership: TheirTM is TheirBody's transform in the welding frame.
// UnWeld separates a previously welded body. Default instances without
// physics typically report Weld false.

namespace TS_FBodyInstance_Behavior_01
{
	bool Observe_Weld_Nominal()
	{
		FBodyInstance Body;
		FBodyInstance TheirBody;
		FTransform TheirTM;
		bool bWelded = Body.Weld(TheirBody, TheirTM);
		FTransform Offset(FRotator::ZeroRotator, FVector(10.0, 0.0, 0.0), FVector::OneVector);
		bool bOffsetWelded = Body.Weld(TheirBody, Offset);
		return !bWelded && !bOffsetWelded;
	}

	bool Observe_UnWeld_Nominal()
	{
		FBodyInstance Body;
		FBodyInstance TheirBody;
		FTransform TheirTM;
		bool bWelded = Body.Weld(TheirBody, TheirTM);
		Body.UnWeld(TheirBody);
		Body.UnWeld(TheirBody);
		return !bWelded;
	}
}
