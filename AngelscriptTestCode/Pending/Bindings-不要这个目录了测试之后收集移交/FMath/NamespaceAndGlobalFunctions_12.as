/**
 * @version v1
 * @summary Observe reciprocal square roots, fractional parts, and exponential helpers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe reciprocal square roots, fractional parts, and exponential helpers.
 * @topic Baseline
 */
// Math::Frac; Math::Exp; Math::Exp2.
// Inputs: InvSqrt 4 and 1; Fractional/Frac 1.25 and -1.25; Exp(0) and
// Exp2(3); both float64 and float32 widths where published.
// Expected observations: InvSqrt(4) is 0.5. Fractional(1.25) is 0.25 and
// Fractional(-1.25) is -0.25. Frac(-1.25) is nonnegative. Exp(0) is 1.
// Exp2(3) is 8.
// Boundary/ownership: Fractional keeps the sign after truncating toward zero.
// Frac is the nonnegative remainder after flooring. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_12
{
	bool Observe_InvSqrt_Nominal()
	{
		float64 Inv64 = Math::InvSqrt(4.0);
		float64 InvOne64 = Math::InvSqrt(1.0);
		float32 Four32 = 4.0;
		float32 One32 = 1.0;
		float32 Inv32 = Math::InvSqrt(Four32);
		float32 InvOne32 = Math::InvSqrt(One32);
		return Math::IsNearlyEqual(Inv64, 0.5) && Math::IsNearlyEqual(InvOne64, 1.0) && Math::IsNearlyEqual(Inv32, float32(0.5), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(InvOne32, float32(1.0), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_InvSqrtEst_Nominal()
	{
		float64 Est64 = Math::InvSqrtEst(4.0);
		float64 EstOne64 = Math::InvSqrtEst(1.0);
		float32 Four32 = 4.0;
		float32 One32 = 1.0;
		float32 Est32 = Math::InvSqrtEst(Four32);
		float32 EstOne32 = Math::InvSqrtEst(One32);
		return Math::IsNearlyEqual(Est64, 0.5, 0.05) && Math::IsNearlyEqual(EstOne64, 1.0, 0.05) && Math::IsNearlyEqual(Est32, float32(0.5), float32(0.05)) && Math::IsNearlyEqual(EstOne32, float32(1.0), float32(0.05));
	}

	bool Observe_Fractional_Nominal()
	{
		float64 Pos64 = Math::Fractional(1.25);
		float64 Neg64 = Math::Fractional(-1.25);
		float64 Whole64 = Math::Fractional(2.0);
		float32 Pos32In = 1.25;
		float32 Neg32In = -1.25;
		float32 Pos32 = Math::Fractional(Pos32In);
		float32 Neg32 = Math::Fractional(Neg32In);
		return Math::IsNearlyEqual(Pos64, 0.25) && Math::IsNearlyEqual(Neg64, -0.25) && Math::IsNearlyEqual(Whole64, 0.0) && Math::IsNearlyEqual(Pos32, float32(0.25)) && Math::IsNearlyEqual(Neg32, float32(-0.25));
	}

	bool Observe_Frac_Nominal()
	{
		float64 Pos64 = Math::Frac(1.25);
		float64 Neg64 = Math::Frac(-1.25);
		float64 Whole64 = Math::Frac(2.0);
		float32 Pos32In = 1.25;
		float32 Neg32In = -1.25;
		float32 Pos32 = Math::Frac(Pos32In);
		float32 Neg32 = Math::Frac(Neg32In);
		bool bFrac64 = Math::IsNearlyEqual(Pos64, 0.25) && Neg64 >= 0.0 && Neg64 < 1.0 && Math::IsNearlyEqual(Whole64, 0.0);
		bool bFrac32 = Math::IsNearlyEqual(Pos32, float32(0.25)) && Neg32 >= 0.0 && Neg32 < 1.0;
		return bFrac64 && bFrac32;
	}

	bool Observe_Exp_Nominal()
	{
		float64 ExpZero = Math::Exp(0.0);
		float64 ExpOne = Math::Exp(1.0);
		return Math::IsNearlyEqual(ExpZero, 1.0) && Math::IsNearlyEqual(ExpOne, EULERS_NUMBER, KINDA_SMALL_NUMBER);
	}

	bool Observe_Exp2_Nominal()
	{
		float64 Exp2Zero = Math::Exp2(0.0);
		float64 Exp2Three = Math::Exp2(3.0);
		return Math::IsNearlyEqual(Exp2Zero, 1.0) && Math::IsNearlyEqual(Exp2Three, 8.0);
	}
}
/** @end */
