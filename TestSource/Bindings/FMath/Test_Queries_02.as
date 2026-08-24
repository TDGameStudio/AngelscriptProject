// Purpose: Observe Math interval membership and floating-point NaN/finite
// queries.
// AS-facing API: Math::IsWithin; Math::IsWithinInclusive; Math::IsNaN;
// Math::IsFinite.
// Inputs: Interval [0, 10); inclusive [0, 10]; 5, 0, 10, -1; NaN from 0/0;
// inf from 1/0; finite 1. float64 and float32/int32 overloads.
// Expected observations: 5 is within both intervals. 10 is excluded from
// IsWithin and included in IsWithinInclusive. NaN is NaN and not finite.
// Inf is not NaN and not finite. 1 is finite and not NaN.
// Boundary/ownership: Min is inclusive. IsWithin Max is exclusive.
// IsWithinInclusive Max is inclusive. NaN and inf are local temporaries.

namespace TS_FMath_Queries_02
{
	bool Observe_IsWithin_Nominal()
	{
		float64 Min64 = 0.0;
		float64 Max64 = 10.0;
		bool bInside64 = Math::IsWithin(5.0, Min64, Max64);
		bool bLower64 = Math::IsWithin(0.0, Min64, Max64);
		bool bUpper64 = Math::IsWithin(10.0, Min64, Max64);
		bool bBelow64 = Math::IsWithin(-1.0, Min64, Max64);

		float32 Min32 = 0.0;
		float32 Max32 = 10.0;
		float32 Five32 = 5.0;
		float32 Ten32 = 10.0;
		float32 Zero32 = 0.0;
		bool bInside32 = Math::IsWithin(Five32, Min32, Max32);
		bool bUpper32 = Math::IsWithin(Ten32, Min32, Max32);
		bool bLower32 = Math::IsWithin(Zero32, Min32, Max32);

		int32 MinI = 0;
		int32 MaxI = 10;
		bool bInsideI = Math::IsWithin(5, MinI, MaxI);
		bool bUpperI = Math::IsWithin(10, MinI, MaxI);
		bool bLowerI = Math::IsWithin(0, MinI, MaxI);
		return bInside64 && bLower64 && !bUpper64 && !bBelow64 && bInside32 && !bUpper32 && bLower32 && bInsideI && !bUpperI && bLowerI;
	}

	bool Observe_IsWithinInclusive_Nominal()
	{
		float64 Min64 = 0.0;
		float64 Max64 = 10.0;
		bool bInside64 = Math::IsWithinInclusive(5.0, Min64, Max64);
		bool bLower64 = Math::IsWithinInclusive(0.0, Min64, Max64);
		bool bUpper64 = Math::IsWithinInclusive(10.0, Min64, Max64);
		bool bBelow64 = Math::IsWithinInclusive(-1.0, Min64, Max64);

		float32 Min32 = 0.0;
		float32 Max32 = 10.0;
		float32 Five32 = 5.0;
		float32 Ten32 = 10.0;
		float32 Zero32 = 0.0;
		bool bInside32 = Math::IsWithinInclusive(Five32, Min32, Max32);
		bool bUpper32 = Math::IsWithinInclusive(Ten32, Min32, Max32);
		bool bLower32 = Math::IsWithinInclusive(Zero32, Min32, Max32);

		int32 MinI = 0;
		int32 MaxI = 10;
		bool bInsideI = Math::IsWithinInclusive(5, MinI, MaxI);
		bool bUpperI = Math::IsWithinInclusive(10, MinI, MaxI);
		bool bLowerI = Math::IsWithinInclusive(0, MinI, MaxI);
		return bInside64 && bLower64 && bUpper64 && !bBelow64 && bInside32 && bUpper32 && bLower32 && bInsideI && bUpperI && bLowerI;
	}

	bool Observe_IsNaN_Nominal()
	{
		float64 Nan64 = 0.0 / 0.0;
		float64 One64 = 1.0;
		float64 Inf64 = 1.0 / 0.0;
		bool bNan64 = Math::IsNaN(Nan64);
		bool bOne64 = Math::IsNaN(One64);
		bool bInf64 = Math::IsNaN(Inf64);

		float32 Zero32 = 0.0;
		float32 Nan32 = Zero32 / Zero32;
		float32 One32 = 1.0;
		float32 Inf32 = One32 / Zero32;
		bool bNan32 = Math::IsNaN(Nan32);
		bool bOne32 = Math::IsNaN(One32);
		bool bInf32 = Math::IsNaN(Inf32);
		return bNan64 && !bOne64 && !bInf64 && bNan32 && !bOne32 && !bInf32;
	}

	bool Observe_IsFinite_Nominal()
	{
		float64 Nan64 = 0.0 / 0.0;
		float64 One64 = 1.0;
		float64 Inf64 = 1.0 / 0.0;
		bool bNan64 = Math::IsFinite(Nan64);
		bool bOne64 = Math::IsFinite(One64);
		bool bInf64 = Math::IsFinite(Inf64);

		float32 Zero32 = 0.0;
		float32 Nan32 = Zero32 / Zero32;
		float32 One32 = 1.0;
		float32 Inf32 = One32 / Zero32;
		bool bNan32 = Math::IsFinite(Nan32);
		bool bOne32 = Math::IsFinite(One32);
		bool bInf32 = Math::IsFinite(Inf32);
		return !bNan64 && bOne64 && !bInf64 && !bNan32 && bOne32 && !bInf32;
	}
}
