/**
 * @version v1
 * @summary Observe FVector3f component extrema, absolute copy, zero tests, normalized-state, and sign vector queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f component extrema, absolute copy, zero tests, normalized-state, and sign vector queries.
 * @topic Baseline
 */
// IsNearlyZero; IsZero; IsNormalized; GetSignVector.
// Inputs: (2,-8,4), zero, unit X, tiny __KINDA_SMALL_NUMBER_flt * 0.5,
// (1,-2,0).
// Expected observations: GetMax of (2,-8,4) is 4. GetAbsMax is 8. GetMin is
// -8. GetAbsMin is 2. GetAbs drops signs. Tiny is nearly zero. Unit X is
// normalized. Sign vector of (1,-2,0) is (1,-1,1).
// Boundary/ownership: Equals uses __KINDA_SMALL_NUMBER_flt. Queries do not
// mutate. Zero components sign as +1.

namespace TS_FVector3f_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FVector3f Left(1.0f, 2.0f, 3.0f);
		FVector3f Right(1.0f, 2.0f, 3.0f);
		FVector3f Perturbed(1.0f + __KINDA_SMALL_NUMBER_flt * 0.5f, 2.0f, 3.0f);
		FVector3f Far(2.0f, 2.0f, 3.0f);
		return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0f);
	}

	bool Observe_GetMax_Nominal()
	{
		return FVector3f(2.0f, -8.0f, 4.0f).GetMax() == 4.0f && FVector3f(0.0f, 0.0f, 0.0f).GetMax() == 0.0f;
	}

	bool Observe_GetAbsMax_Nominal()
	{
		return FVector3f(2.0f, -8.0f, 4.0f).GetAbsMax() == 8.0f && FVector3f(0.0f, 0.0f, 0.0f).GetAbsMax() == 0.0f;
	}

	bool Observe_GetMin_Nominal()
	{
		return FVector3f(2.0f, -8.0f, 4.0f).GetMin() == -8.0f && FVector3f(0.0f, 0.0f, 0.0f).GetMin() == 0.0f;
	}

	bool Observe_GetAbsMin_Nominal()
	{
		return FVector3f(2.0f, -8.0f, 4.0f).GetAbsMin() == 2.0f && FVector3f(-1.0f, -1.0f, -1.0f).GetAbsMin() == 1.0f;
	}

	bool Observe_GetAbs_Nominal()
	{
		FVector3f Abs = FVector3f(-1.0f, 2.0f, -3.0f).GetAbs();
		return Abs.X == 1.0f && Abs.Y == 2.0f && Abs.Z == 3.0f;
	}

	bool Observe_IsNearlyZero_Nominal()
	{
		FVector3f Tiny(__KINDA_SMALL_NUMBER_flt * 0.5f, 0.0f, 0.0f);
		return FVector3f(0.0f, 0.0f, 0.0f).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector3f(1.0f, 0.0f, 0.0f).IsNearlyZero();
	}

	bool Observe_IsZero_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).IsZero() && !FVector3f(0.0f, 0.0f, 1.0f).IsZero();
	}

	bool Observe_IsNormalized_Nominal()
	{
		return FVector3f(1.0f, 0.0f, 0.0f).IsNormalized() && !FVector3f(2.0f, 0.0f, 0.0f).IsNormalized() && !FVector3f(0.0f, 0.0f, 0.0f).IsNormalized();
	}

	bool Observe_GetSignVector_Nominal()
	{
		FVector3f Signs = FVector3f(1.0f, -2.0f, 0.0f).GetSignVector();
		return Signs.X == 1.0f && Signs.Y == -1.0f && Signs.Z == 1.0f;
	}
}
/** @end */
