/**
 * @version v1
 * @summary Observe FVector component extrema, absolute copy, zero tests, normalized-state, and sign vector queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector component extrema, absolute copy, zero tests, normalized-state, and sign vector queries.
 * @topic Baseline
 */
// IsNearlyZero; IsZero; IsNormalized; GetSignVector.
// Inputs: (2,-8,4), zero, unit X, (KINDA_SMALL_NUMBER * 0.5, 0, 0),
// (1,-2,0), and a pair equal within default tolerance.
// Expected observations: GetMax of (2,-8,4) is 4. GetAbsMax is 8. GetMin is
// -8. GetAbsMin is 2. GetAbs drops signs. Zero is exactly zero; a tiny
// vector is nearly zero. Unit X is normalized. Sign vector of (1,-2,0) is
// (1,-1,1).
// Boundary/ownership: Equals uses tolerance unlike operator==. Queries do
// not mutate the receiver. Zero components sign as +1.

namespace TS_FVector_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FVector Left(1, 2, 3);
		FVector Right(1, 2, 3);
		FVector Perturbed(1.0 + KINDA_SMALL_NUMBER * 0.5, 2, 3);
		FVector Far(2, 2, 3);
		return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0);
	}

	bool Observe_GetMax_Nominal()
	{
		return FVector(2, -8, 4).GetMax() == 4.0 && FVector(0, 0, 0).GetMax() == 0.0;
	}

	bool Observe_GetAbsMax_Nominal()
	{
		return FVector(2, -8, 4).GetAbsMax() == 8.0 && FVector(0, 0, 0).GetAbsMax() == 0.0;
	}

	bool Observe_GetMin_Nominal()
	{
		return FVector(2, -8, 4).GetMin() == -8.0 && FVector(0, 0, 0).GetMin() == 0.0;
	}

	bool Observe_GetAbsMin_Nominal()
	{
		return FVector(2, -8, 4).GetAbsMin() == 2.0 && FVector(-1, -1, -1).GetAbsMin() == 1.0;
	}

	bool Observe_GetAbs_Nominal()
	{
		FVector Abs = FVector(-1, 2, -3).GetAbs();
		return Abs.X == 1.0 && Abs.Y == 2.0 && Abs.Z == 3.0;
	}

	bool Observe_IsNearlyZero_Nominal()
	{
		FVector Tiny(KINDA_SMALL_NUMBER * 0.5, 0, 0);
		return FVector(0, 0, 0).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector(1, 0, 0).IsNearlyZero();
	}

	bool Observe_IsZero_Nominal()
	{
		return FVector(0, 0, 0).IsZero() && !FVector(0, 0, 1).IsZero();
	}

	bool Observe_IsNormalized_Nominal()
	{
		return FVector(1, 0, 0).IsNormalized() && !FVector(2, 0, 0).IsNormalized() && !FVector(0, 0, 0).IsNormalized();
	}

	bool Observe_GetSignVector_Nominal()
	{
		FVector Signs = FVector(1, -2, 0).GetSignVector();
		return Signs.X == 1.0 && Signs.Y == -1.0 && Signs.Z == 1.0;
	}
}
/** @end */
