// Purpose: Observe FQuat4f equality/identity/normalization queries, angle,
// NaN, and rotated axes including forward.
// AS-facing API: bool FQuat4f.Equals(const FQuat4f& Other, float32 Tolerance=KINDA_SMALL_NUMBER) const;
// bool FQuat4f.IsIdentity(float32 Tolerance=SMALL_NUMBER) const;
// FQuat4f FQuat4f.GetNormalized(float32 Tolerance = SMALL_NUMBER) const;
// bool FQuat4f.IsNormalized() const; float32 FQuat4f.GetAngle() const;
// bool FQuat4f.ContainsNaN() const; FVector3f FQuat4f.GetAxisX() const;
// FVector3f FQuat4f.GetAxisY() const; FVector3f FQuat4f.GetAxisZ() const;
// FVector3f FQuat4f.GetForwardVector() const;
// Inputs: Identity, (0,0,0,2), yaw 90, KINDA_SMALL_NUMBER, SMALL_NUMBER, and
// a 0/0 W component for NaN.
// Expected observations: Identity Equals itself and IsIdentity. (0,0,0,2) is
// not normalized; GetNormalized restores W=1. Identity angle is 0. Identity
// ContainsNaN is false. Identity axes are +X/+Y/+Z. Yaw 90 forward leans on +Y.
// Boundary/ownership: GetNormalized returns a copy. Equals uses tolerance.

namespace TS_FQuat4f_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FQuat4f Identity = FQuat4f::Identity;
		FQuat4f Copy = FQuat4f::Identity;
		FQuat4f Perturbed(0.0, 0.0, 0.0, 1.0 + KINDA_SMALL_NUMBER * 0.5);
		FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
		bool bExact = Identity.Equals(Copy);
		bool bTolerant = Identity.Equals(Perturbed);
		bool bDefaultTolerance = Identity.Equals(Copy, KINDA_SMALL_NUMBER);
		bool bYawDiffers = Identity.Equals(Yaw);
		return bExact && bTolerant && bDefaultTolerance && !bYawDiffers;
	}

	bool Observe_IsIdentity_Nominal()
	{
		bool bIdentity = FQuat4f::Identity.IsIdentity();
		bool bExplicit = FQuat4f::Identity.IsIdentity(SMALL_NUMBER);
		bool bDoubled = FQuat4f(0.0, 0.0, 0.0, 2.0).IsIdentity();
		bool bYaw = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).IsIdentity();
		return bIdentity && bExplicit && !bDoubled && !bYaw;
	}

	bool Observe_GetNormalized_Nominal()
	{
		FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
		FQuat4f Normalized = Doubled.GetNormalized();
		FQuat4f Explicit = Doubled.GetNormalized(SMALL_NUMBER);
		return Normalized.W == 1.0 && Explicit.W == 1.0 && Doubled.W == 2.0;
	}

	bool Observe_IsNormalized_Nominal()
	{
		return FQuat4f::Identity.IsNormalized() && !FQuat4f(0.0, 0.0, 0.0, 2.0).IsNormalized();
	}

	bool Observe_GetAngle_Nominal()
	{
		float32 IdentityAngle = FQuat4f::Identity.GetAngle();
		float32 YawAngle = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetAngle();
		return IdentityAngle == 0.0 && YawAngle > 1.0;
	}

	bool Observe_ContainsNaN_Nominal()
	{
		bool bIdentityFinite = FQuat4f::Identity.ContainsNaN();
		float32 Zero = 0.0;
		FQuat4f NanQuat(0.0, 0.0, 0.0, Zero / Zero);
		bool bNan = NanQuat.ContainsNaN();
		return !bIdentityFinite && bNan;
	}

	bool Observe_GetAxisX_Nominal()
	{
		FVector3f IdentityX = FQuat4f::Identity.GetAxisX();
		FVector3f YawX = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetAxisX();
		return IdentityX.X == 1.0 && YawX.Y > 0.9;
	}

	bool Observe_GetAxisY_Nominal()
	{
		FVector3f IdentityY = FQuat4f::Identity.GetAxisY();
		return IdentityY.Y == 1.0 && IdentityY.X == 0.0;
	}

	bool Observe_GetAxisZ_Nominal()
	{
		FVector3f IdentityZ = FQuat4f::Identity.GetAxisZ();
		return IdentityZ.Z == 1.0 && IdentityZ.X == 0.0;
	}

	bool Observe_GetForwardVector_Nominal()
	{
		FVector3f Forward = FQuat4f::Identity.GetForwardVector();
		FVector3f YawForward = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetForwardVector();
		return Forward.X == 1.0 && YawForward.Y > 0.9;
	}
}
