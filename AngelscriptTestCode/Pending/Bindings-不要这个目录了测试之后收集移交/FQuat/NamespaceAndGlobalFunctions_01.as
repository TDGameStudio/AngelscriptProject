/**
 * @version v1
 * @summary Observe FQuat::Identity, Euler/rotator factories, lerp/slerp, and rotational error, with a zero-length slerp as the diagnostic companion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FQuat::Identity, Euler/rotator factories, lerp/slerp, and rotational error, with a zero-length slerp as the diagnostic companion.
 * @topic Baseline
 */
// FQuat FQuat::MakeFromEuler(const FVector& Euler);
// FQuat FQuat::MakeFromRotator(const FRotator& Rotator);
// FQuat FQuat::FastLerp(const FQuat& A, const FQuat& B, const float64 Alpha);
// FQuat FQuat::FastBilerp(const FQuat& P00, const FQuat& P10, const FQuat& P01, const FQuat& P11, float64 FracX, float64 FracY);
// FQuat FQuat::Slerp_NotNormalized(const FQuat& Quat1, const FQuat& Quat2, float64 Slerp);
// FQuat FQuat::Slerp(const FQuat& Quat1, const FQuat& Quat2, float64 Slerp);
// float64 FQuat::Error(const FQuat& Q1, const FQuat& Q2);
// float64 FQuat::ErrorAutoNormalize(const FQuat& A, const FQuat& B);
// FQuat FQuat::SlerpFullPath_NotNormalized(const FQuat& Quat1, const FQuat& Quat2, float64 Slerp);
// Inputs: Identity, Euler (0,0,90), Rotator (0,90,0), Alpha/Slerp 0/0.5/1,
// FastBilerp all-identity corners, and a zero quaternion on the failure path.
// Expected observations: Identity is (0,0,0,1). Euler/rotator yaw turns
// Forward toward +Y. Lerp/Slerp at 0 and 1 match the endpoints. Error of
// Identity vs itself is 0; vs yaw is positive.
// Boundary/ownership: Identity is a shared constant. Interpolation returns
// new values. Zero-length Slerp is the diagnostic companion.

namespace TS_FQuat_NamespaceAndGlobalFunctions_01
{
	// FQuat::Identity is the shared (0,0,0,1) constant. Oracle: exact components. Not owned by the caller.
	bool Observe_Surface043_Nominal()
	{
		FQuat Identity = FQuat::Identity;
		return Identity.X == 0.0 && Identity.Y == 0.0 && Identity.Z == 0.0 && Identity.W == 1.0;
	}

	// MakeFromEuler(0,0,90) is yaw 90. Oracle: rotated Forward.Y > 0.9. Returns a new quaternion.
	bool Observe_MakeFromEuler_Nominal()
	{
		FQuat Yaw = FQuat::MakeFromEuler(FVector(0, 0, 90));
		FVector Rotated = Yaw.RotateVector(FVector::ForwardVector);
		return Rotated.Y > 0.9;
	}

	// MakeFromRotator(0,90,0) is yaw 90. Oracle: rotated Forward.Y > 0.9. Returns a new quaternion.
	bool Observe_MakeFromRotator_Nominal()
	{
		FQuat Yaw = FQuat::MakeFromRotator(FRotator(0, 90, 0));
		FVector Rotated = Yaw.RotateVector(FVector::ForwardVector);
		return Rotated.Y > 0.9;
	}

	// FastLerp at 0/1 matches endpoints; mid has non-zero size. Inputs: Identity and yaw 90. New values.
	bool Observe_FastLerp_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::FastLerp(From, To, 0.0);
		FQuat End = FQuat::FastLerp(From, To, 1.0);
		FQuat Mid = FQuat::FastLerp(From, To, 0.5);
		return Start.Equals(From) && End.Equals(To) && Mid.Size() > 0.0;
	}

	// FastBilerp of all-identity corners is identity at (0,0) and non-zero at (0.5,0.5). New values.
	bool Observe_FastBilerp_Nominal()
	{
		FQuat Identity = FQuat::Identity;
		FQuat Result = FQuat::FastBilerp(Identity, Identity, Identity, Identity, 0.5, 0.5);
		FQuat Corner = FQuat::FastBilerp(Identity, Identity, Identity, Identity, 0.0, 0.0);
		return Result.Size() > 0.0 && Corner.Equals(Identity);
	}

	// Slerp_NotNormalized at 0/1 matches endpoints. Inputs: Identity and yaw 90. New values.
	bool Observe_Slerp_NotNormalized_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::Slerp_NotNormalized(From, To, 0.0);
		FQuat End = FQuat::Slerp_NotNormalized(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	// Slerp at 0/1 matches endpoints; mid is normalized. Inputs: Identity and yaw 90. New values.
	bool Observe_Slerp_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::Slerp(From, To, 0.0);
		FQuat End = FQuat::Slerp(From, To, 1.0);
		FQuat Mid = FQuat::Slerp(From, To, 0.5);
		return Start.Equals(From) && End.Equals(To) && Mid.IsNormalized();
	}

	// Error of Identity vs itself is 0; vs yaw 90 is positive. Does not mutate inputs.
	bool Observe_Error_Nominal()
	{
		float64 Same = FQuat::Error(FQuat::Identity, FQuat::Identity);
		float64 Different = FQuat::Error(FQuat::Identity, FQuat(FRotator(0, 90, 0)));
		return Same == 0.0 && Different > 0.0;
	}

	// ErrorAutoNormalize treats (0,0,0,2) as Identity; yaw 90 remains positive. Does not mutate inputs.
	bool Observe_ErrorAutoNormalize_Nominal()
	{
		FQuat Doubled(0.0, 0.0, 0.0, 2.0);
		float64 Same = FQuat::ErrorAutoNormalize(Doubled, FQuat::Identity);
		float64 Different = FQuat::ErrorAutoNormalize(FQuat::Identity, FQuat(FRotator(0, 90, 0)));
		return Same == 0.0 && Different > 0.0;
	}

	// SlerpFullPath_NotNormalized at 0/1 matches endpoints. Inputs: Identity and yaw 90. New values.
	bool Observe_SlerpFullPath_NotNormalized_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::SlerpFullPath_NotNormalized(From, To, 0.0);
		FQuat End = FQuat::SlerpFullPath_NotNormalized(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	void ExerciseExpectedFailure()
	{
		FQuat Zero(0.0, 0.0, 0.0, 0.0);
		FQuat Result = FQuat::Slerp(Zero, Zero, 0.5);
	}
}
/** @end */
