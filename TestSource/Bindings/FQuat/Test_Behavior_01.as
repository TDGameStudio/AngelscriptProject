// Purpose: Observe FQuat default/copy/component constructors, in-place
// normalize, size, log/exp, inverse, and angular distance.
// AS-facing API: FQuat Quat(); FQuat Quat(const FQuat& Q);
// FQuat Quat(float64 X, float64 Y, float64 Z, float64 W);
// void Quat.Normalize(float64 Tolerance = SMALL_NUMBER);
// float64 Quat.Size() const; float64 Quat.SizeSquared() const;
// FQuat Quat.Log() const; FQuat Quat.Exp() const; FQuat Quat.Inverse() const;
// float64 Quat.AngularDistance(const FQuat& Q) const;
// Inputs: Default, copy of Identity, components (0,0,0,1) and (0,0,0,2),
// SMALL_NUMBER omitted and explicit, yaw 90, and Identity vs itself.
// Expected observations: Default and copy are Identity. Normalize of
// (0,0,0,2) yields W=1. Identity Size/SizeSquared are 1. Log/Exp of
// Identity round-trips. Inverse of Identity is Identity. AngularDistance to
// self is 0 and to yaw 90 is about HALF_PI.
// Boundary/ownership: Normalize mutates the receiver. Log/Exp/Inverse
// return new quaternions.

namespace TS_FQuat_Behavior_01
{
	bool Observe_Quat_Nominal()
	{
		FQuat DefaultQuat;
		FQuat Copied(DefaultQuat);
		FQuat Components(0.0, 0.0, 0.0, 1.0);
		return DefaultQuat.W == 1.0 && Copied.W == 1.0 && Components.W == 1.0 && DefaultQuat.X == 0.0;
	}

	bool Observe_Normalize_Nominal()
	{
		FQuat Doubled(0.0, 0.0, 0.0, 2.0);
		Doubled.Normalize();
		FQuat Explicit(0.0, 0.0, 0.0, 2.0);
		Explicit.Normalize(SMALL_NUMBER);
		return Doubled.W == 1.0 && Explicit.W == 1.0 && Doubled.IsNormalized();
	}

	bool Observe_Size_Nominal()
	{
		return FQuat::Identity.Size() == 1.0 && FQuat(0.0, 0.0, 0.0, 2.0).Size() == 2.0;
	}

	bool Observe_SizeSquared_Nominal()
	{
		return FQuat::Identity.SizeSquared() == 1.0 && FQuat(0.0, 0.0, 0.0, 2.0).SizeSquared() == 4.0;
	}

	bool Observe_Log_Nominal()
	{
		FQuat Logged = FQuat::Identity.Log();
		return Logged.X == 0.0 && Logged.Y == 0.0 && Logged.Z == 0.0;
	}

	bool Observe_Exp_Nominal()
	{
		FQuat RoundTrip = FQuat::Identity.Log().Exp();
		return RoundTrip.Equals(FQuat::Identity);
	}

	bool Observe_Inverse_Nominal()
	{
		FQuat IdentityInverse = FQuat::Identity.Inverse();
		FQuat Yaw = FQuat(FRotator(0, 90, 0));
		FQuat Restored = Yaw.Inverse() * Yaw;
		return IdentityInverse.Equals(FQuat::Identity) && Restored.IsIdentity();
	}

	bool Observe_AngularDistance_Nominal()
	{
		float64 Same = FQuat::Identity.AngularDistance(FQuat::Identity);
		float64 Yaw = FQuat::Identity.AngularDistance(FQuat(FRotator(0, 90, 0)));
		return Same == 0.0 && Yaw > 1.0;
	}
}
