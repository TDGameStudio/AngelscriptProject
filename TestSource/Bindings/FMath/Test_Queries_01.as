// Purpose: Observe Math reflection, nearly-equal/zero, power-of-two, and
// shortest signed angle-delta queries.
// AS-facing API: Math::GetReflectionVector; Math::IsNearlyEqual;
// Math::IsNearlyZero; Math::IsPowerOfTwo; Math::FindDeltaAngleDegrees;
// Math::FindDeltaAngleRadians.
// Inputs: Direction (1,0,0) with unit normal (-1,0,0); 1 vs 1 and 1 vs 2;
// 0 and SMALL_NUMBER/2; 8/7/0/1; 0-to-90 degrees and 0-to-HALF_PI radians;
// a zero SurfaceNormal as the diagnostic companion.
// Expected observations: Reflection X is -1. Equal pairs are true; 1 vs 2 is
// false. Zero is nearly zero; 1 is not. 8 and 1 are powers of two; 7 and 0
// are not. 0-to-90 delta is 90 degrees.
// Boundary/ownership: Call Math::, never FMath::. ErrorTolerance defaults to
// SMALL_NUMBER. Zero SurfaceNormal is a degenerate reflection.

namespace TS_FMath_Queries_01
{
	bool Observe_GetReflectionVector_Nominal()
	{
		FVector Direction(1.0, 0.0, 0.0);
		FVector SurfaceNormal(-1.0, 0.0, 0.0);
		FVector Reflected = Math::GetReflectionVector(Direction, SurfaceNormal);
		return Reflected.X == -1.0 && Reflected.Y == 0.0 && Reflected.Z == 0.0;
	}

	bool Observe_IsNearlyEqual_Nominal()
	{
		float64 Left64 = 1.0;
		float64 Right64 = 1.0;
		bool bEqual64Default = Math::IsNearlyEqual(Left64, Right64);
		bool bEqual64Explicit = Math::IsNearlyEqual(Left64, Right64, SMALL_NUMBER);
		bool bUnequal64 = Math::IsNearlyEqual(Left64, 2.0);
		float64 Near64 = 1.0 + SMALL_NUMBER * 0.5;
		bool bTolerant64 = Math::IsNearlyEqual(Left64, Near64);

		float32 Left32 = 1.0;
		float32 Right32 = 1.0;
		float32 Two32 = 2.0;
		float32 Tolerance32 = float32(SMALL_NUMBER);
		bool bEqual32Default = Math::IsNearlyEqual(Left32, Right32);
		bool bEqual32Explicit = Math::IsNearlyEqual(Left32, Right32, Tolerance32);
		bool bUnequal32 = Math::IsNearlyEqual(Left32, Two32);
		return bEqual64Default && bEqual64Explicit && !bUnequal64 && bTolerant64 && bEqual32Default && bEqual32Explicit && !bUnequal32;
	}

	bool Observe_IsNearlyZero_Nominal()
	{
		float64 Zero64 = 0.0;
		bool bZero64Default = Math::IsNearlyZero(Zero64);
		bool bZero64Explicit = Math::IsNearlyZero(Zero64, SMALL_NUMBER);
		bool bOne64 = Math::IsNearlyZero(1.0);
		float64 Tiny64 = SMALL_NUMBER * 0.5;
		bool bTiny64 = Math::IsNearlyZero(Tiny64);

		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 Tolerance32 = float32(SMALL_NUMBER);
		bool bZero32Default = Math::IsNearlyZero(Zero32);
		bool bZero32Explicit = Math::IsNearlyZero(Zero32, Tolerance32);
		bool bOne32 = Math::IsNearlyZero(One32);
		return bZero64Default && bZero64Explicit && !bOne64 && bTiny64 && bZero32Default && bZero32Explicit && !bOne32;
	}

	bool Observe_IsPowerOfTwo_Nominal()
	{
		bool bEight = Math::IsPowerOfTwo(8);
		bool bSeven = Math::IsPowerOfTwo(7);
		bool bZero = Math::IsPowerOfTwo(0);
		bool bOne = Math::IsPowerOfTwo(1);
		bool bNegative = Math::IsPowerOfTwo(-8);
		return bEight && !bSeven && !bZero && bOne && !bNegative;
	}

	bool Observe_FindDeltaAngleDegrees_Nominal()
	{
		float64 Delta90_64 = Math::FindDeltaAngleDegrees(0.0, 90.0);
		float64 DeltaWrap64 = Math::FindDeltaAngleDegrees(10.0, 350.0);
		bool bDegrees64 = Math::IsNearlyEqual(Delta90_64, 90.0) && Math::IsNearlyEqual(DeltaWrap64, -20.0);

		float32 Start32 = 0.0;
		float32 Target32 = 90.0;
		float32 Delta90_32 = Math::FindDeltaAngleDegrees(Start32, Target32);
		float32 WrapStart32 = 10.0;
		float32 WrapTarget32 = 350.0;
		float32 DeltaWrap32 = Math::FindDeltaAngleDegrees(WrapStart32, WrapTarget32);
		bool bDegrees32 = Math::IsNearlyEqual(Delta90_32, float32(90.0)) && Math::IsNearlyEqual(DeltaWrap32, float32(-20.0));
		return bDegrees64 && bDegrees32;
	}

	bool Observe_FindDeltaAngleRadians_Nominal()
	{
		float64 DeltaHalfPi64 = Math::FindDeltaAngleRadians(0.0, HALF_PI);
		bool bRadians64 = Math::IsNearlyEqual(DeltaHalfPi64, HALF_PI);

		float32 Zero32 = 0.0;
		float32 HalfPi32 = float32(HALF_PI);
		float32 DeltaHalfPi32 = Math::FindDeltaAngleRadians(Zero32, HalfPi32);
		bool bRadians32 = Math::IsNearlyEqual(DeltaHalfPi32, HalfPi32);
		return bRadians64 && bRadians32;
	}

	void ExerciseExpectedFailure()
	{
		FVector Direction(1.0, 0.0, 0.0);
		FVector ZeroNormal;
		Math::GetReflectionVector(Direction, ZeroNormal);
	}
}
