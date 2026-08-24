// Purpose: Observe FVector2D extrema, absolute copy, zero tests, safe normal,
// NaN detection, and sign vector.
// AS-facing API: Equals; GetMax; GetAbsMax; GetMin; GetAbs; IsNearlyZero;
// IsZero; GetSafeNormal; ContainsNaN; GetSignVector.
// Inputs: (2,-8), zero, unit X, tiny KINDA_SMALL_NUMBER * 0.5, (3,4),
// (1,-2), omitted SMALL_NUMBER default, and 0/0 for NaN.
// Expected observations: GetMax of (2,-8) is 2. GetAbsMax is 8. GetMin is
// -8. GetAbs is (2,8). Tiny is nearly zero. (3,4) safe-normal is (0.6,0.8).
// Zero safe-normal is zero. Finite is not NaN. Sign of (1,-2) is (1,-1).
// Boundary/ownership: Equals uses tolerance. GetSafeNormal returns zero
// below Tolerance. Queries do not mutate.

namespace TS_FVector2D_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FVector2D Left(1, 2);
		FVector2D Right(1, 2);
		FVector2D Perturbed(1.0 + KINDA_SMALL_NUMBER * 0.5, 2);
		FVector2D Far(2, 2);
		return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0);
	}

	bool Observe_GetMax_Nominal()
	{
		return FVector2D(2, -8).GetMax() == 2.0 && FVector2D(0, 0).GetMax() == 0.0;
	}

	bool Observe_GetAbsMax_Nominal()
	{
		return FVector2D(2, -8).GetAbsMax() == 8.0 && FVector2D(0, 0).GetAbsMax() == 0.0;
	}

	bool Observe_GetMin_Nominal()
	{
		return FVector2D(2, -8).GetMin() == -8.0 && FVector2D(0, 0).GetMin() == 0.0;
	}

	bool Observe_GetAbs_Nominal()
	{
		FVector2D Abs = FVector2D(-1, 2).GetAbs();
		return Abs.X == 1.0 && Abs.Y == 2.0;
	}

	bool Observe_IsNearlyZero_Nominal()
	{
		FVector2D Tiny(KINDA_SMALL_NUMBER * 0.5, 0);
		return FVector2D(0, 0).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector2D(1, 0).IsNearlyZero();
	}

	bool Observe_IsZero_Nominal()
	{
		return FVector2D(0, 0).IsZero() && !FVector2D(0, 1).IsZero();
	}

	bool Observe_GetSafeNormal_Nominal()
	{
		FVector2D Unit = FVector2D(3, 4).GetSafeNormal();
		FVector2D Zero = FVector2D(0, 0).GetSafeNormal();
		return Unit.Equals(FVector2D(0.6, 0.8)) && Zero.IsZero();
	}

	bool Observe_ContainsNaN_Nominal()
	{
		float64 Zero = 0.0;
		FVector2D NonFinite(Zero / Zero, 0);
		return !FVector2D(1, 2).ContainsNaN() && NonFinite.ContainsNaN();
	}

	bool Observe_GetSignVector_Nominal()
	{
		FVector2D Signs = FVector2D(1, -2).GetSignVector();
		return Signs.X == 1.0 && Signs.Y == -1.0;
	}
}
