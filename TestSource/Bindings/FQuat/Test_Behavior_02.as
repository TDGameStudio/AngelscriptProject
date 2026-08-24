// Purpose: Observe FQuat XYZW fields, shortest-arc enforcement, rotator/
// axis-angle/Quat4f constructors, Euler conversion, and RotateVector.
// AS-facing API: float64 Quat.X; float64 Quat.Y; float64 Quat.Z; float64 Quat.W;
// void Quat.EnforceShortestArcWith(const FQuat& Other);
// FQuat Quat(const FRotator& R); FQuat Quat(FVector Axis, float64 AngleRad);
// FQuat Quat(const FQuat4f& Quat); FVector Quat.Euler() const;
// FVector Quat.RotateVector(FVector V) const;
// Inputs: Components (0.1,0.2,0.3,0.9), flipped Identity vs Identity,
// Rotator (0,90,0), UpVector with HALF_PI, FQuat4f Identity, and Forward.
// Expected observations: Fields store the constructed components. Flipped W
// becomes positive after EnforceShortestArcWith. Rotator and axis-angle yaw
// turn Forward toward +Y. FQuat4f conversion keeps W=1. Identity Euler is 0.
// Boundary/ownership: Fields alias components. EnforceShortestArcWith
// mutates the receiver. Constructors copy values.

namespace TS_FQuat_Behavior_02
{
	// FQuat.X stores the constructed X of (0.1, 0.2, 0.3, 0.9). Oracle: X == 0.1. Value copy.
	bool Observe_Surface028_Nominal()
	{
		return FQuat(0.1, 0.2, 0.3, 0.9).X == 0.1;
	}

	// FQuat.Y stores the constructed Y of (0.1, 0.2, 0.3, 0.9). Oracle: Y == 0.2. Value copy.
	bool Observe_Surface029_Nominal()
	{
		return FQuat(0.1, 0.2, 0.3, 0.9).Y == 0.2;
	}

	// FQuat.Z stores the constructed Z of (0.1, 0.2, 0.3, 0.9). Oracle: Z == 0.3. Value copy.
	bool Observe_Surface030_Nominal()
	{
		return FQuat(0.1, 0.2, 0.3, 0.9).Z == 0.3;
	}

	// FQuat.W stores the constructed W of (0.1, 0.2, 0.3, 0.9). Oracle: W == 0.9. Value copy.
	bool Observe_Surface031_Nominal()
	{
		return FQuat(0.1, 0.2, 0.3, 0.9).W == 0.9;
	}

	// EnforceShortestArcWith flips W into the same hemisphere as Other. Inputs: W=-1 vs Identity. Mutates receiver.
	bool Observe_EnforceShortestArcWith_Nominal()
	{
		FQuat Flipped(0.0, 0.0, 0.0, -1.0);
		Flipped.EnforceShortestArcWith(FQuat::Identity);
		FQuat AlreadyShort = FQuat::Identity;
		AlreadyShort.EnforceShortestArcWith(FQuat::Identity);
		return Flipped.W > 0.0 && AlreadyShort.W == 1.0;
	}

	// Rotator, axis-angle, and FQuat4f constructors. Inputs: yaw 90, Up+HALF_PI, Identity4f. Oracle: Forward maps toward +Y, W=1.
	bool Observe_Quat_Nominal()
	{
		FQuat FromRotator(FRotator(0, 90, 0));
		FQuat FromAxis(FVector::UpVector, HALF_PI);
		FQuat FromSingle(FQuat4f::Identity);
		return FromRotator.RotateVector(FVector::ForwardVector).Y > 0.9 && FromAxis.RotateVector(FVector::ForwardVector).Y > 0.9 && FromSingle.W == 1.0;
	}

	// Euler() of Identity is zero; yaw 90 has a non-zero yaw component. Returns a new FVector.
	bool Observe_Euler_Nominal()
	{
		FVector IdentityEuler = FQuat::Identity.Euler();
		FVector YawEuler = FQuat(FRotator(0, 90, 0)).Euler();
		return IdentityEuler.X == 0.0 && IdentityEuler.Z == 0.0 && YawEuler.Z > 89.0;
	}

	// RotateVector of Identity leaves Forward; yaw 90 sends Forward toward +Y. Returns a new FVector.
	bool Observe_RotateVector_Nominal()
	{
		FVector IdentityForward = FQuat::Identity.RotateVector(FVector::ForwardVector);
		FVector YawForward = FQuat(FRotator(0, 90, 0)).RotateVector(FVector::ForwardVector);
		return IdentityForward.X == 1.0 && YawForward.Y > 0.9;
	}
}
