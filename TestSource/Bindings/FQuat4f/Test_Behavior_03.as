// Purpose: Observe FQuat4f rotate/unrotate, XYZ vector extraction, rotator
// conversion, and InitFromString success/failure.
// AS-facing API: FVector3f FQuat4f.RotateVector(FVector3f V) const;
// FVector3f FQuat4f.UnrotateVector(FVector3f V) const;
// FVector3f FQuat4f.Vector() const; FRotator3f FQuat4f.Rotator() const;
// bool FQuat4f.InitFromString(const FString& SourceString);
// Inputs: Identity and yaw 90, ForwardVector, formatter text of Identity,
// and empty string as the failed parse.
// Expected observations: Identity leaves Forward unchanged. Yaw 90 sends
// Forward toward +Y. Unrotate recovers Forward. Identity Vector is
// ForwardVector. Identity Rotator is zero. InitFromString of Identity text
// succeeds; empty text fails.
// Boundary/ownership: InitFromString mutates the receiver. Rotate/Unrotate/
// Vector/Rotator return new values.

namespace TS_FQuat4f_Behavior_03
{
	bool Observe_RotateVector_Nominal()
	{
		FVector3f IdentityForward = FQuat4f::Identity.RotateVector(FVector3f::ForwardVector);
		FVector3f YawForward = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).RotateVector(FVector3f::ForwardVector);
		return IdentityForward.X == 1.0 && YawForward.Y > 0.9;
	}

	bool Observe_UnrotateVector_Nominal()
	{
		FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
		FVector3f Rotated = Yaw.RotateVector(FVector3f::ForwardVector);
		FVector3f Restored = Yaw.UnrotateVector(Rotated);
		FVector3f IdentityUnrotated = FQuat4f::Identity.UnrotateVector(FVector3f::ForwardVector);
		return Restored.X > 0.9 && IdentityUnrotated.X == 1.0;
	}

	bool Observe_Vector_Nominal()
	{
		FVector3f IdentityVector = FQuat4f::Identity.Vector();
		FVector3f YawVector = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).Vector();
		return IdentityVector.X == 1.0 && IdentityVector.Z == 0.0 && YawVector.Y > 0.9;
	}

	bool Observe_Rotator_Nominal()
	{
		FRotator3f IdentityRotator = FQuat4f::Identity.Rotator();
		FRotator3f YawRotator = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).Rotator();
		return IdentityRotator.Pitch == 0.0 && IdentityRotator.Yaw == 0.0 && YawRotator.Yaw > 0.0;
	}

	bool Observe_InitFromString_Nominal()
	{
		FString Text = f"{FQuat4f::Identity}";
		FQuat4f Parsed;
		bool bParsed = Parsed.InitFromString(Text);
		FQuat4f Failed;
		bool bEmptyFailed = Failed.InitFromString("");
		return bParsed && Parsed.Equals(FQuat4f::Identity) && !bEmptyFailed;
	}
}
