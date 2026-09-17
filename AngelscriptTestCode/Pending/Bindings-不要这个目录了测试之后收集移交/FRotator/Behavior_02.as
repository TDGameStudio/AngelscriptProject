/**
 * @version v1
 * @summary Observe in-place Normalize, forward/quaternion/Euler conversions, vector rotation, and InitFromString.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe in-place Normalize, forward/quaternion/Euler conversions, vector rotation, and InitFromString.
 * @topic Baseline
 */
// UnrotateVector; InitFromString.
// Inputs: (0,270,0) for Normalize, ZeroRotator, yaw 90, (10,20,30) Euler,
// ForwardVector, "P=10 Y=20 R=30", and empty text.
// Expected observations: Normalize writes yaw -90. Zero Vector is ForwardVector.
// Zero Quaternion is Identity. Euler of (10,20,30) is (30,10,20). Yaw 90
// rotates X onto Y. InitFromString succeeds for P/Y/R text and fails on empty.
// Boundary/ownership: Normalize mutates the receiver. InitFromString mutates
// and reports success. Euler is (Roll, Pitch, Yaw).

namespace TS_FRotator_Behavior_02
{
	bool Observe_Normalize_Nominal()
	{
		FRotator Over(0.0, 270.0, 0.0);
		Over.Normalize();
		FRotator Zero;
		Zero.Normalize();
		return Over.Yaw == -90.0 && Zero.IsZero();
	}

	bool Observe_Vector_Nominal()
	{
		FVector ZeroForward = FRotator::ZeroRotator.Vector();
		FVector Yaw90Forward = FRotator(0.0, 90.0, 0.0).Vector();
		return ZeroForward.Equals(FVector::ForwardVector) && Yaw90Forward.Equals(FVector::RightVector);
	}

	bool Observe_Quaternion_Nominal()
	{
		FQuat Identity = FRotator::ZeroRotator.Quaternion();
		FQuat FromYaw = FRotator(0.0, 90.0, 0.0).Quaternion();
		return Identity.Equals(FQuat::Identity) && !FromYaw.Equals(FQuat::Identity);
	}

	bool Observe_Euler_Nominal()
	{
		FVector Euler = FRotator(10.0, 20.0, 30.0).Euler();
		FVector ZeroEuler = FRotator::ZeroRotator.Euler();
		return Euler.X == 30.0 && Euler.Y == 10.0 && Euler.Z == 20.0 && ZeroEuler.IsNearlyZero();
	}

	bool Observe_RotateVector_Nominal()
	{
		FRotator Yaw90(0.0, 90.0, 0.0);
		FVector Rotated = Yaw90.RotateVector(FVector::ForwardVector);
		FVector Unchanged = FRotator::ZeroRotator.RotateVector(FVector::ForwardVector);
		return Rotated.Equals(FVector::RightVector) && Unchanged.Equals(FVector::ForwardVector);
	}

	bool Observe_UnrotateVector_Nominal()
	{
		FRotator Yaw90(0.0, 90.0, 0.0);
		FVector Unrotated = Yaw90.UnrotateVector(FVector::RightVector);
		FVector RoundTrip = Yaw90.UnrotateVector(Yaw90.RotateVector(FVector(1.0, 2.0, 3.0)));
		return Unrotated.Equals(FVector::ForwardVector) && RoundTrip.Equals(FVector(1.0, 2.0, 3.0));
	}

	bool Observe_InitFromString_Nominal()
	{
		FRotator Parsed;
		bool bValid = Parsed.InitFromString("P=10 Y=20 R=30");
		FRotator Failed;
		bool bEmptyFailed = Failed.InitFromString("");
		return bValid && Parsed.Pitch == 10.0 && Parsed.Yaw == 20.0 && Parsed.Roll == 30.0 && !bEmptyFailed;
	}
}
/** @end */
