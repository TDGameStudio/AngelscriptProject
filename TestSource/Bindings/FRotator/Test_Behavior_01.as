// Purpose: Observe FRotator constructors, Pitch/Yaw/Roll fields, and Clamp.
// AS-facing API: FRotator(Pitch,Yaw,Roll); FRotator(); FRotator(F);
// FRotator(Other); FRotator(Quat); FRotator(FRotator3f); Pitch; Yaw; Roll;
// Clamp().
// Inputs: (10,20,30), default, scalar 7, copy, identity quat, FRotator3f
// (1,2,3), and 370 yaw for Clamp.
// Expected observations: Component ctor stores Pitch,Yaw,Roll in that order.
// Default and identity quat are zero. Scalar fills all axes. Copy is
// independent. FRotator3f converts. Clamp of 370 yaw is 10.
// Boundary/ownership: Constructors are Pitch,Yaw,Roll. Clamp returns a new
// rotator in [0, 360).

namespace TS_FRotator_Behavior_01
{
	// Component, default, scalar, copy, quat, and FRotator3f constructors. Copy stays independent after mutating the source.
	bool Observe_Rotator_Nominal()
	{
		FRotator Components(10.0, 20.0, 30.0);
		FRotator DefaultRotator;
		FRotator Scalar(7.0);
		FRotator Copied(Components);
		FRotator FromQuat(FQuat::Identity);
		FRotator FromSingle(FRotator3f(1.0, 2.0, 3.0));
		Components.Pitch = 0.0;
		bool bComponents = Copied.Pitch == 10.0 && Copied.Yaw == 20.0 && Copied.Roll == 30.0;
		bool bDefaultZero = DefaultRotator.IsZero();
		bool bScalarFilled = Scalar.Pitch == 7.0 && Scalar.Yaw == 7.0 && Scalar.Roll == 7.0;
		bool bFromQuatZero = FromQuat.IsNearlyZero();
		bool bFromSingle = FromSingle.Pitch == 1.0 && FromSingle.Yaw == 2.0 && FromSingle.Roll == 3.0;
		return bComponents && bDefaultZero && bScalarFilled && bFromQuatZero && bFromSingle && Copied.Pitch == 10.0;
	}

	// FRotator.Pitch stores the constructed pitch of (10,20,30). Oracle: Pitch == 10. Value copy.
	bool Observe_Surface008_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		return Rotator.Pitch == 10.0;
	}

	// FRotator.Yaw stores the constructed yaw of (10,20,30). Oracle: Yaw == 20. Value copy.
	bool Observe_Surface009_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		return Rotator.Yaw == 20.0;
	}

	// FRotator.Roll stores the constructed roll of (10,20,30). Oracle: Roll == 30. Value copy.
	bool Observe_Surface010_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		return Rotator.Roll == 30.0;
	}

	// Clamp of yaw 370 is 10 in [0,360); ZeroRotator stays zero. Returns a new rotator.
	bool Observe_Clamp_Nominal()
	{
		FRotator Over(0.0, 370.0, 0.0);
		FRotator Clamped = Over.Clamp();
		FRotator ZeroClamped = FRotator::ZeroRotator.Clamp();
		return Clamped.Yaw == 10.0 && ZeroClamped.IsZero() && Over.Yaw == 370.0;
	}
}
