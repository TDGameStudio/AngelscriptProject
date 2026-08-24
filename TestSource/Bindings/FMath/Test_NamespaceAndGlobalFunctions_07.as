// Purpose: Observe 2D/rotator/quaternion interp-to helpers, axis-angle
// rotators, and random point/rotator factories.
// AS-facing API: Math::Vector2DInterpTo; Math::RInterpConstantTo;
// Math::RInterpTo; Math::RotatorFromAxisAndAngle;
// Math::RandomPointInBoundingBox; Math::RandomRotator;
// Math::QInterpConstantTo; Math::QInterpTo.
// Inputs: (0,0) toward (10,0); rotators 0 toward 90 yaw; axis (0,0,1) angle
// 90; box center 0 half-size (1,1,1); RandomRotator with and without roll;
// Identity toward 90-yaw quats; InterpSpeed 0.
// Expected observations: InterpSpeed 0 snaps to Target. Axis-angle 90 about
// Z produces ~90 yaw. Random points stay inside the box. RandomRotator(false)
// keeps roll 0. Results are unit-length quats after interp.
// Boundary/ownership: Random APIs are observed by range, not exact values.
// Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_07
{
	bool Observe_Vector2DInterpTo_Nominal()
	{
		FVector2D Current(0.0, 0.0);
		FVector2D Target(10.0, 0.0);
		FVector2D Eased = Math::Vector2DInterpTo(Current, Target, 0.1, 1.0);
		FVector2D Snapped = Math::Vector2DInterpTo(Current, Target, 0.1, 0.0);
		bool bBetween = Eased.X > 0.0 && Eased.X < 10.0;
		bool bSpeedZeroSnaps = Math::IsNearlyEqual(Snapped.X, 10.0);
		return bBetween && bSpeedZeroSnaps;
	}

	bool Observe_RInterpConstantTo_Nominal()
	{
		FRotator Current = FRotator::ZeroRotator;
		FRotator Target(0.0, 90.0, 0.0);
		FRotator Stepped = Math::RInterpConstantTo(Current, Target, 0.5, 40.0);
		FRotator Snapped = Math::RInterpConstantTo(Current, Target, 0.5, 0.0);
		bool bMovedToward = Stepped.Yaw > 0.0 && Stepped.Yaw <= 90.0;
		bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
		return bMovedToward && bSpeedZeroSnaps;
	}

	bool Observe_RInterpTo_Nominal()
	{
		FRotator Current = FRotator::ZeroRotator;
		FRotator Target(0.0, 90.0, 0.0);
		FRotator Eased = Math::RInterpTo(Current, Target, 0.1, 1.0);
		FRotator Snapped = Math::RInterpTo(Current, Target, 0.1, 0.0);
		bool bMovedToward = Eased.Yaw > 0.0 && Eased.Yaw < 90.0;
		bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
		return bMovedToward && bSpeedZeroSnaps;
	}

	bool Observe_RotatorFromAxisAndAngle_Nominal()
	{
		FVector Axis(0.0, 0.0, 1.0);
		FRotator Yaw90 = Math::RotatorFromAxisAndAngle(Axis, 90.0);
		FRotator Zero = Math::RotatorFromAxisAndAngle(Axis, 0.0);
		bool bYawNear90 = Math::IsNearlyEqual(Math::Abs(Yaw90.Yaw), 90.0, KINDA_SMALL_NUMBER);
		bool bZeroAngle = Zero.Equals(FRotator::ZeroRotator, KINDA_SMALL_NUMBER);
		return bYawNear90 && bZeroAngle;
	}

	bool Observe_RandomPointInBoundingBox_Nominal()
	{
		FVector Center(0.0, 0.0, 0.0);
		FVector HalfSize(1.0, 1.0, 1.0);
		FVector Sample = Math::RandomPointInBoundingBox(Center, HalfSize);
		FVector SampleAgain = Math::RandomPointInBoundingBox(Center, HalfSize);
		bool bInside = Sample.X >= -1.0 && Sample.X <= 1.0 && Sample.Y >= -1.0 && Sample.Y <= 1.0 && Sample.Z >= -1.0 && Sample.Z <= 1.0;
		bool bAgainInside = SampleAgain.X >= -1.0 && SampleAgain.X <= 1.0 && SampleAgain.Y >= -1.0 && SampleAgain.Y <= 1.0 && SampleAgain.Z >= -1.0 && SampleAgain.Z <= 1.0;
		return bInside && bAgainInside;
	}

	bool Observe_RandomRotator_Nominal()
	{
		FRotator WithRoll = Math::RandomRotator(true);
		FRotator WithoutRoll = Math::RandomRotator(false);
		bool bWithRollFinite = Math::IsFinite(WithRoll.Pitch) && Math::IsFinite(WithRoll.Yaw) && Math::IsFinite(WithRoll.Roll);
		bool bRollHeldZero = Math::IsNearlyEqual(WithoutRoll.Roll, 0.0);
		return bWithRollFinite && bRollHeldZero;
	}

	bool Observe_QInterpConstantTo_Nominal()
	{
		FQuat Current = FQuat::Identity;
		FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
		FQuat Stepped = Math::QInterpConstantTo(Current, Target, 0.5, 40.0);
		FQuat Snapped = Math::QInterpConstantTo(Current, Target, 0.5, 0.0);
		FQuat4f Current4 = FQuat4f::Identity;
		FQuat4f Target4 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Stepped4 = Math::QInterpConstantTo(Current4, Target4, 0.5, 40.0);
		FQuat4f Snapped4 = Math::QInterpConstantTo(Current4, Target4, 0.5, 0.0);
		bool bMoved = !Stepped.Equals(Current, KINDA_SMALL_NUMBER);
		bool bSnapped = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
		bool bMoved4 = !Stepped4.Equals(Current4, float32(KINDA_SMALL_NUMBER));
		bool bSnapped4 = Snapped4.Equals(Target4, float32(KINDA_SMALL_NUMBER));
		return bMoved && bSnapped && bMoved4 && bSnapped4;
	}

	bool Observe_QInterpTo_Nominal()
	{
		FQuat Current = FQuat::Identity;
		FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
		FQuat Eased = Math::QInterpTo(Current, Target, 0.1, 1.0);
		FQuat Snapped = Math::QInterpTo(Current, Target, 0.1, 0.0);
		FQuat4f Current4 = FQuat4f::Identity;
		FQuat4f Target4 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Eased4 = Math::QInterpTo(Current4, Target4, 0.1, 1.0);
		FQuat4f Snapped4 = Math::QInterpTo(Current4, Target4, 0.1, 0.0);
		bool bMoved = !Eased.Equals(Current, KINDA_SMALL_NUMBER);
		bool bSnapped = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
		bool bMoved4 = !Eased4.Equals(Current4, float32(KINDA_SMALL_NUMBER));
		bool bSnapped4 = Snapped4.Equals(Target4, float32(KINDA_SMALL_NUMBER));
		return bMoved && bSnapped && bMoved4 && bSnapped4;
	}
}
