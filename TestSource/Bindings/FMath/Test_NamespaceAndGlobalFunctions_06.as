// Purpose: Observe remaining CubicInterpDerivative overloads and vector
// interp-to helpers.
// AS-facing API: Math::CubicInterpDerivative; Math::VInterpNormalRotationTo;
// Math::VInterpConstantTo; Math::VInterpTo; Math::Vector2DInterpConstantTo.
// Inputs: Zero-tangent rotators/vectors at alpha 0 and 0.5; Current (1,0,0)
// toward (0,1,0) at 90 deg/s for 1s; (0,0,0) toward (10,0,0) at constant
// speed 4 for 0.5s; InterpSpeed 0 snap; 2D (0,0) toward (10,0).
// Expected observations: Zero-tangent derivatives are finite. Normal rotation
// of 90 degrees reaches the target axis. Constant interp of 2 units lands on
// (2,0,0). InterpSpeed 0 snaps to Target.
// Boundary/ownership: InterpSpeed 0 snaps to Target. Results are new values.
// Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_06
{
	bool Observe_CubicInterpDerivative_Nominal()
	{
		FRotator RP0 = FRotator::ZeroRotator;
		FRotator RP1(0.0, 90.0, 0.0);
		FRotator RT = FRotator::ZeroRotator;
		FRotator DerivR64 = Math::CubicInterpDerivative(RP0, RT, RP1, RT, 0.0);
		FRotator DerivR64Mid = Math::CubicInterpDerivative(RP0, RT, RP1, RT, 0.5);

		float32 P0_32 = 0.0;
		float32 P1_32 = 1.0;
		float32 T0_32 = 0.0;
		float32 T1_32 = 0.0;
		float32 Zero32 = 0.0;
		float32 Half32 = 0.5;
		float32 DerivS32 = Math::CubicInterpDerivative(P0_32, T0_32, P1_32, T1_32, Zero32);
		float32 DerivM32 = Math::CubicInterpDerivative(P0_32, T0_32, P1_32, T1_32, Half32);

		FVector VP0(0.0, 0.0, 0.0);
		FVector VP1(10.0, 0.0, 0.0);
		FVector VT;
		FVector DerivV32 = Math::CubicInterpDerivative(VP0, VT, VP1, VT, Zero32);
		FRotator DerivR32 = Math::CubicInterpDerivative(RP0, RT, RP1, RT, Zero32);

		FVector3f P0_3f(0.0, 0.0, 0.0);
		FVector3f P1_3f(10.0, 0.0, 0.0);
		FVector3f T3f;
		FVector3f Deriv3f = Math::CubicInterpDerivative(P0_3f, T3f, P1_3f, T3f, Zero32);

		FRotator3f R3P0 = FRotator3f::ZeroRotator;
		FRotator3f R3P1(0.0, 90.0, 0.0);
		FRotator3f R3T = FRotator3f::ZeroRotator;
		FRotator3f DerivR3 = Math::CubicInterpDerivative(R3P0, R3T, R3P1, R3T, Zero32);

		bool bRot64 = Math::IsFinite(DerivR64.Yaw) && Math::IsFinite(DerivR64Mid.Yaw);
		bool bScalar32 = Math::IsNearlyEqual(DerivS32, Zero32, float32(KINDA_SMALL_NUMBER)) && Math::IsFinite(DerivM32);
		bool bRest = DerivV32.IsNearlyZero() && Math::IsFinite(DerivR32.Yaw) && Math::IsFinite(Deriv3f.X) && Math::IsFinite(DerivR3.Yaw);
		return bRot64 && bScalar32 && bRest;
	}

	bool Observe_VInterpNormalRotationTo_Nominal()
	{
		FVector Current(1.0, 0.0, 0.0);
		FVector Target(0.0, 1.0, 0.0);
		FVector Rotated = Math::VInterpNormalRotationTo(Current, Target, 1.0, 90.0);
		FVector Unmoved = Math::VInterpNormalRotationTo(Current, Target, 0.0, 90.0);
		bool bReachedTarget = Rotated.Equals(Target, KINDA_SMALL_NUMBER);
		bool bZeroDeltaStays = Unmoved.Equals(Current, KINDA_SMALL_NUMBER);
		return bReachedTarget && bZeroDeltaStays;
	}

	bool Observe_VInterpConstantTo_Nominal()
	{
		FVector Current(0.0, 0.0, 0.0);
		FVector Target(10.0, 0.0, 0.0);
		FVector Stepped = Math::VInterpConstantTo(Current, Target, 0.5, 4.0);
		FVector Snapped = Math::VInterpConstantTo(Current, Target, 0.5, 0.0);
		FVector Arrived = Math::VInterpConstantTo(Target, Target, 0.5, 4.0);
		bool bMovedTwo = Stepped.Equals(FVector(2.0, 0.0, 0.0), KINDA_SMALL_NUMBER);
		bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
		bool bAtTarget = Arrived.Equals(Target, KINDA_SMALL_NUMBER);
		return bMovedTwo && bSpeedZeroSnaps && bAtTarget;
	}

	bool Observe_VInterpTo_Nominal()
	{
		FVector Current(0.0, 0.0, 0.0);
		FVector Target(10.0, 0.0, 0.0);
		FVector Eased = Math::VInterpTo(Current, Target, 0.1, 1.0);
		FVector Snapped = Math::VInterpTo(Current, Target, 0.1, 0.0);
		bool bBetween = Eased.X > 0.0 && Eased.X < 10.0;
		bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
		return bBetween && bSpeedZeroSnaps;
	}

	bool Observe_Vector2DInterpConstantTo_Nominal()
	{
		FVector2D Current(0.0, 0.0);
		FVector2D Target(10.0, 0.0);
		FVector2D Stepped = Math::Vector2DInterpConstantTo(Current, Target, 0.5, 4.0);
		FVector2D Snapped = Math::Vector2DInterpConstantTo(Current, Target, 0.5, 0.0);
		bool bMovedTwo = Math::IsNearlyEqual(Stepped.X, 2.0) && Math::IsNearlyEqual(Stepped.Y, 0.0);
		bool bSpeedZeroSnaps = Math::IsNearlyEqual(Snapped.X, 10.0);
		return bMovedTwo && bSpeedZeroSnaps;
	}
}
