// Purpose: Observe ZeroRotator, axis wrap helpers, Euler construction, and
// single/two-axis MakeFrom rotations.
// AS-facing API: FRotator::ZeroRotator; NormalizeAxis; ClampAxis; MakeFromEuler;
// MakeFromX; MakeFromY; MakeFromZ; MakeFromXY; MakeFromXZ; MakeFromYX.
// Inputs: Angles 270, -90, 370, 0; Euler (30,10,20) as Roll/Pitch/Yaw; world
// Forward, Right, and Up axes.
// Expected observations: ZeroRotator is zero. NormalizeAxis(270) is -90.
// ClampAxis(-90) is 270. MakeFromEuler stores Pitch 10, Yaw 20, Roll 30.
// MakeFrom* of the world axes is nearly ZeroRotator.
// Boundary/ownership: NormalizeAxis uses (-180, 180]. ClampAxis uses [0, 360).
// MakeFrom* returns a new rotator and prioritizes the first named axis.

namespace TS_FRotator_NamespaceAndGlobalFunctions_01
{
	// FRotator::ZeroRotator is the shared zero constant. Oracle: IsZero and exact 0 components. Not owned by the caller.
	bool Observe_Surface030_Nominal()
	{
		FRotator Zero = FRotator::ZeroRotator;
		return Zero.IsZero() && Zero.Pitch == 0.0 && Zero.Yaw == 0.0 && Zero.Roll == 0.0;
	}

	// NormalizeAxis maps 270 to -90 and -270 to 90, leaving 0 unchanged. Degrees in (-180, 180].
	bool Observe_NormalizeAxis_Nominal()
	{
		float64 Wrapped = FRotator::NormalizeAxis(270.0);
		float64 Negative = FRotator::NormalizeAxis(-270.0);
		float64 Unchanged = FRotator::NormalizeAxis(0.0);
		return Wrapped == -90.0 && Negative == 90.0 && Unchanged == 0.0;
	}

	// ClampAxis maps -90 to 270 and 370 to 10, leaving 0 unchanged. Degrees in [0, 360).
	bool Observe_ClampAxis_Nominal()
	{
		float64 FromNegative = FRotator::ClampAxis(-90.0);
		float64 FromOver = FRotator::ClampAxis(370.0);
		float64 Unchanged = FRotator::ClampAxis(0.0);
		return FromNegative == 270.0 && FromOver == 10.0 && Unchanged == 0.0;
	}

	// MakeFromEuler(30,10,20) stores Roll/Pitch/Yaw as Pitch=10, Yaw=20, Roll=30. Returns a new rotator.
	bool Observe_MakeFromEuler_Nominal()
	{
		FRotator FromEuler = FRotator::MakeFromEuler(FVector(30.0, 10.0, 20.0));
		return FromEuler.Pitch == 10.0 && FromEuler.Yaw == 20.0 && FromEuler.Roll == 30.0;
	}

	// MakeFromX(Forward) is ZeroRotator. Returns a new rotator.
	bool Observe_MakeFromX_Nominal()
	{
		FRotator FromX = FRotator::MakeFromX(FVector::ForwardVector);
		return FromX.Equals(FRotator::ZeroRotator);
	}

	// MakeFromY(Right) is ZeroRotator. Returns a new rotator.
	bool Observe_MakeFromY_Nominal()
	{
		FRotator FromY = FRotator::MakeFromY(FVector::RightVector);
		return FromY.Equals(FRotator::ZeroRotator);
	}

	// MakeFromZ(Up) is ZeroRotator. Returns a new rotator.
	bool Observe_MakeFromZ_Nominal()
	{
		FRotator FromZ = FRotator::MakeFromZ(FVector::UpVector);
		return FromZ.Equals(FRotator::ZeroRotator);
	}

	// MakeFromXY(Forward, Right) is ZeroRotator. Returns a new rotator.
	bool Observe_MakeFromXY_Nominal()
	{
		FRotator FromXY = FRotator::MakeFromXY(FVector::ForwardVector, FVector::RightVector);
		return FromXY.Equals(FRotator::ZeroRotator);
	}

	// MakeFromXZ(Forward, Up) is ZeroRotator. Returns a new rotator.
	bool Observe_MakeFromXZ_Nominal()
	{
		FRotator FromXZ = FRotator::MakeFromXZ(FVector::ForwardVector, FVector::UpVector);
		return FromXZ.Equals(FRotator::ZeroRotator);
	}

	// MakeFromYX(Right, Forward) is ZeroRotator. Returns a new rotator.
	bool Observe_MakeFromYX_Nominal()
	{
		FRotator FromYX = FRotator::MakeFromYX(FVector::RightVector, FVector::ForwardVector);
		return FromYX.Equals(FRotator::ZeroRotator);
	}
}
