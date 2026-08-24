// Purpose: Observe FRotator3f quaternion/Euler conversion, vector rotation,
// FQuat4f/FRotator constructors, and InitFromString.
// AS-facing API: Quaternion(); Euler(); RotateVector; UnrotateVector;
// FRotator3f(const FQuat4f&); FRotator3f(const FRotator&); InitFromString.
// Inputs: ZeroRotator, yaw 90, (10,20,30), identity quat, FRotator (1,2,3),
// "P=10 Y=20 R=30", and empty text.
// Expected observations: Zero Quaternion is Identity. Euler of (10,20,30) is
// (30,10,20). Yaw 90 rotates X onto Y. Identity quat constructs zero. FRotator
// converts. InitFromString succeeds for P/Y/R text and fails on empty.
// Boundary/ownership: Euler is (Roll, Pitch, Yaw). InitFromString mutates the
// receiver.

namespace TS_FRotator3f_Behavior_02
{
	bool Observe_Quaternion_Nominal()
	{
		FQuat4f Identity = FRotator3f::ZeroRotator.Quaternion();
		FQuat4f FromYaw = FRotator3f(0.0, 90.0, 0.0).Quaternion();
		return Identity.Equals(FQuat4f::Identity) && !FromYaw.Equals(FQuat4f::Identity);
	}

	bool Observe_Euler_Nominal()
	{
		FVector3f Euler = FRotator3f(10.0, 20.0, 30.0).Euler();
		FVector3f ZeroEuler = FRotator3f::ZeroRotator.Euler();
		return Euler.X == 30.0 && Euler.Y == 10.0 && Euler.Z == 20.0 && ZeroEuler.Equals(FVector3f::ZeroVector);
	}

	bool Observe_RotateVector_Nominal()
	{
		FRotator3f Yaw90(0.0, 90.0, 0.0);
		FVector3f Rotated = Yaw90.RotateVector(FVector3f::ForwardVector);
		FVector3f Unchanged = FRotator3f::ZeroRotator.RotateVector(FVector3f::ForwardVector);
		return Rotated.Equals(FVector3f::RightVector) && Unchanged.Equals(FVector3f::ForwardVector);
	}

	bool Observe_UnrotateVector_Nominal()
	{
		FRotator3f Yaw90(0.0, 90.0, 0.0);
		FVector3f Unrotated = Yaw90.UnrotateVector(FVector3f::RightVector);
		FVector3f RoundTrip = Yaw90.UnrotateVector(Yaw90.RotateVector(FVector3f(1.0, 2.0, 3.0)));
		return Unrotated.Equals(FVector3f::ForwardVector) && RoundTrip.Equals(FVector3f(1.0, 2.0, 3.0));
	}

	bool Observe_Rotator_Nominal()
	{
		FRotator3f FromQuat(FQuat4f::Identity);
		FRotator3f FromDouble(FRotator(1.0, 2.0, 3.0));
		return FromQuat.IsNearlyZero() && FromDouble.Pitch == 1.0 && FromDouble.Yaw == 2.0 && FromDouble.Roll == 3.0;
	}

	bool Observe_InitFromString_Nominal()
	{
		FRotator3f Parsed;
		bool bValid = Parsed.InitFromString("P=10 Y=20 R=30");
		FRotator3f Failed;
		bool bEmptyFailed = Failed.InitFromString("");
		return bValid && Parsed.Pitch == 10.0 && Parsed.Yaw == 20.0 && Parsed.Roll == 30.0 && !bEmptyFailed;
	}
}
