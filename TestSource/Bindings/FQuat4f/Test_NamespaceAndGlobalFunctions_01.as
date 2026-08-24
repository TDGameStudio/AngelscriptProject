// Purpose: Observe FQuat4f::Identity, Euler factory, lerp/slerp, error, and
// full-path slerp, with a zero-length slerp as the diagnostic companion.
// AS-facing API: const FQuat4f FQuat4f::Identity;
// FQuat4f FQuat4f::MakeFromEuler(const FVector3f& Euler);
// FQuat4f FQuat4f::FastLerp(const FQuat4f& A, const FQuat4f& B, const float32 Alpha);
// FQuat4f FQuat4f::FastBilerp(const FQuat4f& P00, const FQuat4f& P10, const FQuat4f& P01, const FQuat4f& P11, float32 FracX, float32 FracY);
// FQuat4f FQuat4f::Slerp_NotNormalized(const FQuat4f& Quat1, const FQuat4f& Quat2, float32 Slerp);
// FQuat4f FQuat4f::Slerp(const FQuat4f& Quat1, const FQuat4f& Quat2, float32 Slerp);
// float32 FQuat4f::Error(const FQuat4f& Q1, const FQuat4f& Q2);
// float32 FQuat4f::ErrorAutoNormalize(const FQuat4f& A, const FQuat4f& B);
// FQuat4f FQuat4f::SlerpFullPath_NotNormalized(const FQuat4f& Quat1, const FQuat4f& Quat2, float32 Slerp);
// FQuat4f FQuat4f::SlerpFullPath(const FQuat4f& Quat1, const FQuat4f& Quat2, float32 Slerp);
// Inputs: Identity, Euler (0,0,90), Alpha/Slerp 0/0.5/1, FastBilerp
// all-identity corners, and a zero quaternion on the failure path.
// Expected observations: Identity is (0,0,0,1). Euler yaw turns Forward
// toward +Y. Lerp/Slerp at 0 and 1 match the endpoints. Error of Identity
// vs itself is 0; vs yaw is positive.
// Boundary/ownership: Identity is a shared constant. Interpolation returns
// new values. Zero-length Slerp is the diagnostic companion.

namespace TS_FQuat4f_NamespaceAndGlobalFunctions_01
{
	// FQuat4f::Identity is the shared (0,0,0,1) constant. Oracle: exact components. Not owned by the caller.
	bool Observe_Surface055_Nominal()
	{
		FQuat4f Identity = FQuat4f::Identity;
		return Identity.X == 0.0 && Identity.Y == 0.0 && Identity.Z == 0.0 && Identity.W == 1.0;
	}

	// MakeFromEuler(0,0,90) is yaw 90. Oracle: rotated Forward.Y > 0.9. Returns a new quaternion.
	bool Observe_MakeFromEuler_Nominal()
	{
		FQuat4f Yaw = FQuat4f::MakeFromEuler(FVector3f(0, 0, 90));
		FVector3f Rotated = Yaw.RotateVector(FVector3f::ForwardVector);
		return Rotated.Y > 0.9;
	}

	// FastLerp at 0/1 matches endpoints; mid has non-zero size. Inputs: Identity and yaw 90. New values.
	bool Observe_FastLerp_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::FastLerp(From, To, 0.0);
		FQuat4f End = FQuat4f::FastLerp(From, To, 1.0);
		FQuat4f Mid = FQuat4f::FastLerp(From, To, 0.5);
		return Start.Equals(From) && End.Equals(To) && Mid.Size() > 0.0;
	}

	// FastBilerp of all-identity corners is identity at (0,0) and non-zero at (0.5,0.5). New values.
	bool Observe_FastBilerp_Nominal()
	{
		FQuat4f Identity = FQuat4f::Identity;
		FQuat4f Result = FQuat4f::FastBilerp(Identity, Identity, Identity, Identity, 0.5, 0.5);
		FQuat4f Corner = FQuat4f::FastBilerp(Identity, Identity, Identity, Identity, 0.0, 0.0);
		return Result.Size() > 0.0 && Corner.Equals(Identity);
	}

	// Slerp_NotNormalized at 0/1 matches endpoints. Inputs: Identity and yaw 90. New values.
	bool Observe_Slerp_NotNormalized_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::Slerp_NotNormalized(From, To, 0.0);
		FQuat4f End = FQuat4f::Slerp_NotNormalized(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	// Slerp at 0/1 matches endpoints; mid is normalized. Inputs: Identity and yaw 90. New values.
	bool Observe_Slerp_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::Slerp(From, To, 0.0);
		FQuat4f End = FQuat4f::Slerp(From, To, 1.0);
		FQuat4f Mid = FQuat4f::Slerp(From, To, 0.5);
		return Start.Equals(From) && End.Equals(To) && Mid.IsNormalized();
	}

	// Error of Identity vs itself is 0; vs yaw 90 is positive. Does not mutate inputs.
	bool Observe_Error_Nominal()
	{
		float32 Same = FQuat4f::Error(FQuat4f::Identity, FQuat4f::Identity);
		float32 Different = FQuat4f::Error(FQuat4f::Identity, FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
		return Same == 0.0 && Different > 0.0;
	}

	// ErrorAutoNormalize treats (0,0,0,2) as Identity; yaw 90 remains positive. Does not mutate inputs.
	bool Observe_ErrorAutoNormalize_Nominal()
	{
		FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
		float32 Same = FQuat4f::ErrorAutoNormalize(Doubled, FQuat4f::Identity);
		float32 Different = FQuat4f::ErrorAutoNormalize(FQuat4f::Identity, FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
		return Same == 0.0 && Different > 0.0;
	}

	// SlerpFullPath_NotNormalized at 0/1 matches endpoints. Inputs: Identity and yaw 90. New values.
	bool Observe_SlerpFullPath_NotNormalized_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::SlerpFullPath_NotNormalized(From, To, 0.0);
		FQuat4f End = FQuat4f::SlerpFullPath_NotNormalized(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	// SlerpFullPath at 0/1 matches endpoints. Inputs: Identity and yaw 90. New values.
	bool Observe_SlerpFullPath_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::SlerpFullPath(From, To, 0.0);
		FQuat4f End = FQuat4f::SlerpFullPath(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	void ExerciseExpectedFailure()
	{
		FQuat4f Zero(0.0, 0.0, 0.0, 0.0);
		FQuat4f Result = FQuat4f::Slerp(Zero, Zero, 0.5);
	}
}
