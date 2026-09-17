/**
 * @version v1
 * @summary Observe FVector2f extrema, absolute copy, zero tests, safe normal, NaN detection, and sign vector.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f extrema, absolute copy, zero tests, safe normal, NaN detection, and sign vector.
 * @topic Baseline
 */
// IsZero; GetSafeNormal; ContainsNaN; GetSignVector.
// Inputs: (2,-8), zero, unit X, tiny __KINDA_SMALL_NUMBER_flt * 0.5, (3,4),
// (1,-2), omitted float32 defaults, 0/0 for NaN.
// Expected observations: GetMax of (2,-8) is 2. GetAbsMax is 8. GetMin is
// -8. GetAbs is (2,8). Tiny is nearly zero. (3,4) safe-normal is (0.6,0.8).
// Finite is not NaN. Sign of (1,-2) is (1,-1).
// Boundary/ownership: Equals uses __KINDA_SMALL_NUMBER_flt. GetSafeNormal
// uses __SMALL_NUMBER_flt. Queries do not mutate.

namespace TS_FVector2f_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FVector2f Left(1.0f, 2.0f);
		FVector2f Right(1.0f, 2.0f);
		FVector2f Perturbed(1.0f + __KINDA_SMALL_NUMBER_flt * 0.5f, 2.0f);
		FVector2f Far(2.0f, 2.0f);
		return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0f);
	}

	bool Observe_GetMax_Nominal()
	{
		return FVector2f(2.0f, -8.0f).GetMax() == 2.0f && FVector2f(0.0f, 0.0f).GetMax() == 0.0f;
	}

	bool Observe_GetAbsMax_Nominal()
	{
		return FVector2f(2.0f, -8.0f).GetAbsMax() == 8.0f && FVector2f(0.0f, 0.0f).GetAbsMax() == 0.0f;
	}

	bool Observe_GetMin_Nominal()
	{
		return FVector2f(2.0f, -8.0f).GetMin() == -8.0f && FVector2f(0.0f, 0.0f).GetMin() == 0.0f;
	}

	bool Observe_GetAbs_Nominal()
	{
		FVector2f Abs = FVector2f(-1.0f, 2.0f).GetAbs();
		return Abs.X == 1.0f && Abs.Y == 2.0f;
	}

	bool Observe_IsNearlyZero_Nominal()
	{
		FVector2f Tiny(__KINDA_SMALL_NUMBER_flt * 0.5f, 0.0f);
		return FVector2f(0.0f, 0.0f).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector2f(1.0f, 0.0f).IsNearlyZero();
	}

	bool Observe_IsZero_Nominal()
	{
		return FVector2f(0.0f, 0.0f).IsZero() && !FVector2f(0.0f, 1.0f).IsZero();
	}

	bool Observe_GetSafeNormal_Nominal()
	{
		FVector2f Unit = FVector2f(3.0f, 4.0f).GetSafeNormal();
		FVector2f Zero = FVector2f(0.0f, 0.0f).GetSafeNormal();
		return Unit.Equals(FVector2f(0.6f, 0.8f)) && Zero.IsZero();
	}

	bool Observe_ContainsNaN_Nominal()
	{
		float32 Zero = 0.0f;
		FVector2f NonFinite(Zero / Zero, 0.0f);
		return !FVector2f(1.0f, 2.0f).ContainsNaN() && NonFinite.ContainsNaN();
	}

	bool Observe_GetSignVector_Nominal()
	{
		FVector2f Signs = FVector2f(1.0f, -2.0f).GetSignVector();
		return Signs.X == 1.0f && Signs.Y == -1.0f;
	}
}
/** @end */
