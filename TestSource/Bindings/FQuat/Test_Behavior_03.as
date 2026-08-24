// Purpose: Observe FQuat unrotate, XYZ vector extraction, rotator conversion,
// and InitFromString success/failure.
// AS-facing API: FVector Quat.UnrotateVector(FVector V) const;
// FVector Quat.Vector() const; FRotator Quat.Rotator() const;
// bool Quat.InitFromString(const FString& SourceString);
// Inputs: Identity and yaw 90, ForwardVector, formatter text of Identity,
// and empty string as the failed parse.
// Expected observations: Unrotate of a yaw-rotated Forward recovers Forward.
// Identity Vector is ForwardVector. Identity Rotator is zero. InitFromString
// of Identity text succeeds; empty text fails.
// Boundary/ownership: InitFromString mutates the receiver. Unrotate/Vector/
// Rotator return new values.

namespace TS_FQuat_Behavior_03
{
	bool Observe_UnrotateVector_Nominal()
	{
		FQuat Yaw(FRotator(0, 90, 0));
		FVector Rotated = Yaw.RotateVector(FVector::ForwardVector);
		FVector Restored = Yaw.UnrotateVector(Rotated);
		FVector IdentityUnrotated = FQuat::Identity.UnrotateVector(FVector::ForwardVector);
		return Restored.X > 0.9 && IdentityUnrotated.X == 1.0;
	}

	bool Observe_Vector_Nominal()
	{
		FVector IdentityVector = FQuat::Identity.Vector();
		FVector YawVector = FQuat(FRotator(0, 90, 0)).Vector();
		return IdentityVector.Equals(FVector::ForwardVector) && YawVector.Y > 0.9;
	}

	bool Observe_Rotator_Nominal()
	{
		FRotator IdentityRotator = FQuat::Identity.Rotator();
		FRotator YawRotator = FQuat(FRotator(0, 90, 0)).Rotator();
		return IdentityRotator.Pitch == 0.0 && IdentityRotator.Yaw == 0.0 && YawRotator.Yaw > 0.0;
	}

	bool Observe_InitFromString_Nominal()
	{
		FString Text = f"{FQuat::Identity}";
		FQuat Parsed;
		bool bParsed = Parsed.InitFromString(Text);
		FQuat Failed;
		bool bEmptyFailed = Failed.InitFromString("");
		return bParsed && Parsed.Equals(FQuat::Identity) && !bEmptyFailed;
	}
}
