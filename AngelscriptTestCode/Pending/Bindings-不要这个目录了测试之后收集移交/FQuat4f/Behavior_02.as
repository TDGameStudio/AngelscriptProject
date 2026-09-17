/**
 * @version v1
 * @summary Observe FQuat4f W, in-place normalize, size, log/exp, inverse, angular distance, shortest-arc enforcement, and Euler conversion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FQuat4f W, in-place normalize, size, log/exp, inverse, angular distance, shortest-arc enforcement, and Euler conversion.
 * @topic Baseline
 */
// float32 FQuat4f.Size() const; float32 FQuat4f.SizeSquared() const;
// FQuat4f FQuat4f.Log() const; FQuat4f FQuat4f.Exp() const;
// FQuat4f FQuat4f.Inverse() const; float32 FQuat4f.AngularDistance(const FQuat4f& Q) const;
// void FQuat4f.EnforceShortestArcWith(const FQuat4f& Other);
// FVector3f FQuat4f.Euler() const;
// Inputs: Components (0.1,0.2,0.3,0.9), (0,0,0,2), SMALL_NUMBER omitted and
// explicit, Identity, yaw 90, and flipped Identity.
// Expected observations: W stores 0.9. Normalize of (0,0,0,2) yields W=1.
// Identity Size/SizeSquared are 1. Log/Exp of Identity round-trips. Inverse
// of Identity is Identity. AngularDistance to self is 0. Flipped W becomes
// positive. Identity Euler is 0.
// Boundary/ownership: Normalize and EnforceShortestArcWith mutate the
// receiver. Log/Exp/Inverse return new quaternions.

namespace TS_FQuat4f_Behavior_02
{
	// FQuat4f.W stores the constructed W of (0.1, 0.2, 0.3, 0.9). Oracle: W == 0.9. Value copy.
	bool Observe_Surface011_Nominal()
	{
		return FQuat4f(0.1, 0.2, 0.3, 0.9).W == 0.9;
	}

	// Normalize of (0,0,0,2) with default and SMALL_NUMBER yields W=1. Mutates the receiver.
	bool Observe_Normalize_Nominal()
	{
		FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
		Doubled.Normalize();
		FQuat4f Explicit(0.0, 0.0, 0.0, 2.0);
		Explicit.Normalize(SMALL_NUMBER);
		return Doubled.W == 1.0 && Explicit.W == 1.0 && Doubled.IsNormalized();
	}

	// Identity Size is 1; (0,0,0,2) Size is 2. Does not mutate.
	bool Observe_Size_Nominal()
	{
		return FQuat4f::Identity.Size() == 1.0 && FQuat4f(0.0, 0.0, 0.0, 2.0).Size() == 2.0;
	}

	// Identity SizeSquared is 1; (0,0,0,2) SizeSquared is 4. Does not mutate.
	bool Observe_SizeSquared_Nominal()
	{
		return FQuat4f::Identity.SizeSquared() == 1.0 && FQuat4f(0.0, 0.0, 0.0, 2.0).SizeSquared() == 4.0;
	}

	// Log of Identity has zero XYZ. Returns a new quaternion.
	bool Observe_Log_Nominal()
	{
		FQuat4f Logged = FQuat4f::Identity.Log();
		return Logged.X == 0.0 && Logged.Y == 0.0 && Logged.Z == 0.0;
	}

	// Exp of Identity.Log() round-trips to Identity. Returns a new quaternion.
	bool Observe_Exp_Nominal()
	{
		FQuat4f RoundTrip = FQuat4f::Identity.Log().Exp();
		return RoundTrip.Equals(FQuat4f::Identity);
	}

	// Inverse of Identity is Identity; yaw * inverse(yaw) is identity. Returns a new quaternion.
	bool Observe_Inverse_Nominal()
	{
		FQuat4f IdentityInverse = FQuat4f::Identity.Inverse();
		FQuat4f Yaw = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Restored = Yaw.Inverse() * Yaw;
		return IdentityInverse.Equals(FQuat4f::Identity) && Restored.IsIdentity();
	}

	// AngularDistance to self is 0; to yaw 90 is about HALF_PI. Does not mutate.
	bool Observe_AngularDistance_Nominal()
	{
		float32 Same = FQuat4f::Identity.AngularDistance(FQuat4f::Identity);
		float32 Yaw = FQuat4f::Identity.AngularDistance(FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
		return Same == 0.0 && Yaw > 1.0;
	}

	// EnforceShortestArcWith flips W=-1 into the Identity hemisphere. Mutates the receiver.
	bool Observe_EnforceShortestArcWith_Nominal()
	{
		FQuat4f Flipped(0.0, 0.0, 0.0, -1.0);
		Flipped.EnforceShortestArcWith(FQuat4f::Identity);
		FQuat4f AlreadyShort = FQuat4f::Identity;
		AlreadyShort.EnforceShortestArcWith(FQuat4f::Identity);
		return Flipped.W > 0.0 && AlreadyShort.W == 1.0;
	}

	// Euler of Identity is zero; yaw 90 has a non-zero yaw component. Returns a new FVector3f.
	bool Observe_Euler_Nominal()
	{
		FVector3f IdentityEuler = FQuat4f::Identity.Euler();
		FVector3f YawEuler = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).Euler();
		return IdentityEuler.X == 0.0 && IdentityEuler.Z == 0.0 && YawEuler.Z > 89.0;
	}
}
/** @end */
