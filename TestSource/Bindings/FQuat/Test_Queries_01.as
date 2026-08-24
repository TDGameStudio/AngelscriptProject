// Purpose: Observe FQuat equality/identity/normalization queries, angle, NaN,
// FindBetween factories, and the rotated X axis.
// AS-facing API: bool Quat.Equals(const FQuat& Other, float64 Tolerance=KINDA_SMALL_NUMBER) const;
// bool Quat.IsIdentity(float64 Tolerance=SMALL_NUMBER) const;
// FQuat Quat.GetNormalized(float64 Tolerance = SMALL_NUMBER) const;
// bool Quat.IsNormalized() const; float64 Quat.GetAngle() const;
// bool Quat.ContainsNaN() const;
// FQuat FQuat::FindBetween(const FVector& Vector1, const FVector& Vector2);
// FQuat FQuat::FindBetweenVectors(const FVector& Vector1, const FVector& Vector2);
// FQuat FQuat::FindBetweenNormals(const FVector& Normal1, const FVector& Normal2);
// FVector Quat.GetAxisX() const;
// Inputs: Identity, (0,0,0,2), yaw 90, KINDA_SMALL_NUMBER, SMALL_NUMBER,
// Forward/Right, and a 0/0 W component for NaN.
// Expected observations: Identity Equals itself and IsIdentity. (0,0,0,2) is
// not normalized; GetNormalized restores W=1. Identity angle is 0. Identity
// ContainsNaN is false. FindBetween(Forward, Right) rotates Forward toward +Y.
// Identity GetAxisX is +X.
// Boundary/ownership: Factories return new quaternions. Equals uses
// tolerance; == is not used here.

namespace TS_FQuat_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FQuat Identity = FQuat::Identity;
		FQuat Copy = FQuat::Identity;
		FQuat Perturbed(0.0, 0.0, 0.0, 1.0 + KINDA_SMALL_NUMBER * 0.5);
		FQuat Yaw(FRotator(0, 90, 0));
		bool bExact = Identity.Equals(Copy);
		bool bTolerant = Identity.Equals(Perturbed);
		bool bDefaultTolerance = Identity.Equals(Copy, KINDA_SMALL_NUMBER);
		bool bYawDiffers = Identity.Equals(Yaw);
		return bExact && bTolerant && bDefaultTolerance && !bYawDiffers;
	}

	bool Observe_IsIdentity_Nominal()
	{
		bool bIdentity = FQuat::Identity.IsIdentity();
		bool bExplicit = FQuat::Identity.IsIdentity(SMALL_NUMBER);
		bool bDoubled = FQuat(0.0, 0.0, 0.0, 2.0).IsIdentity();
		bool bYaw = FQuat(FRotator(0, 90, 0)).IsIdentity();
		return bIdentity && bExplicit && !bDoubled && !bYaw;
	}

	bool Observe_GetNormalized_Nominal()
	{
		FQuat Doubled(0.0, 0.0, 0.0, 2.0);
		FQuat Normalized = Doubled.GetNormalized();
		FQuat Explicit = Doubled.GetNormalized(SMALL_NUMBER);
		return Normalized.W == 1.0 && Explicit.W == 1.0 && Doubled.W == 2.0;
	}

	bool Observe_IsNormalized_Nominal()
	{
		return FQuat::Identity.IsNormalized() && !FQuat(0.0, 0.0, 0.0, 2.0).IsNormalized();
	}

	bool Observe_GetAngle_Nominal()
	{
		float64 IdentityAngle = FQuat::Identity.GetAngle();
		float64 YawAngle = FQuat(FRotator(0, 90, 0)).GetAngle();
		return IdentityAngle == 0.0 && YawAngle > 1.0;
	}

	bool Observe_ContainsNaN_Nominal()
	{
		bool bIdentityFinite = FQuat::Identity.ContainsNaN();
		float64 Zero = 0.0;
		FQuat NanQuat(0.0, 0.0, 0.0, Zero / Zero);
		bool bNan = NanQuat.ContainsNaN();
		return !bIdentityFinite && bNan;
	}

	bool Observe_FindBetween_Nominal()
	{
		FQuat Same = FQuat::FindBetween(FVector::ForwardVector, FVector::ForwardVector);
		FQuat Turn = FQuat::FindBetween(FVector::ForwardVector, FVector::RightVector);
		FVector Rotated = Turn.RotateVector(FVector::ForwardVector);
		return Same.IsIdentity() && Rotated.Y > 0.9;
	}

	bool Observe_FindBetweenVectors_Nominal()
	{
		FQuat Turn = FQuat::FindBetweenVectors(FVector::ForwardVector, FVector::RightVector);
		FVector Rotated = Turn.RotateVector(FVector::ForwardVector);
		return Rotated.Y > 0.9 && Rotated.X < 0.1;
	}

	bool Observe_FindBetweenNormals_Nominal()
	{
		FQuat Turn = FQuat::FindBetweenNormals(FVector::ForwardVector, FVector::RightVector);
		FVector Rotated = Turn.RotateVector(FVector::ForwardVector);
		return Rotated.Y > 0.9;
	}

	bool Observe_GetAxisX_Nominal()
	{
		FVector IdentityX = FQuat::Identity.GetAxisX();
		FVector YawX = FQuat(FRotator(0, 90, 0)).GetAxisX();
		return IdentityX.X == 1.0 && YawX.Y > 0.9;
	}
}
