// Purpose: Observe float64 Atan2/Sqrt/Pow and the float32 exponential and
// trigonometric first half.
// AS-facing API: Math::Atan2; Math::Sqrt; Math::Pow; Math::Exp; Math::Exp2;
// Math::Loge; Math::Log2; Math::LogX; Math::Fmod; Math::Sin.
// Inputs: Atan2(1,0) and Atan2(0,1); Sqrt(4); Pow(2,3); float32 Exp(0)/Exp2(3);
// Loge(1); Log2(8); LogX(10,100); Fmod(5,2); Sin(0) and Sin(HALF_PI).
// Expected observations: Atan2(1,0) is HALF_PI. Sqrt(4) is 2. Pow(2,3) is 8.
// Float32 Exp(0) is 1 and Exp2(3) is 8. Log and Fmod match the float64
// counterparts. Sin(HALF_PI) is 1.
// Boundary/ownership: Atan2 is quadrant-aware. Log Value is positive. Fmod Y
// is a nonzero divisor. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_14
{
	bool Observe_Atan2_Nominal()
	{
		float64 Atan2Y = Math::Atan2(1.0, 0.0);
		float64 Atan2X = Math::Atan2(0.0, 1.0);
		return Math::IsNearlyEqual(Atan2Y, HALF_PI) && Math::IsNearlyEqual(Atan2X, 0.0);
	}

	bool Observe_Sqrt_Nominal()
	{
		float64 SqrtFour = Math::Sqrt(4.0);
		float64 SqrtZero = Math::Sqrt(0.0);
		return Math::IsNearlyEqual(SqrtFour, 2.0) && Math::IsNearlyEqual(SqrtZero, 0.0);
	}

	bool Observe_Pow_Nominal()
	{
		float64 Eight = Math::Pow(2.0, 3.0);
		float64 One = Math::Pow(5.0, 0.0);
		return Math::IsNearlyEqual(Eight, 8.0) && Math::IsNearlyEqual(One, 1.0);
	}

	bool Observe_Exp_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 ExpZero = Math::Exp(Zero32);
		float32 ExpOne = Math::Exp(One32);
		return Math::IsNearlyEqual(ExpZero, float32(1.0)) && Math::IsNearlyEqual(ExpOne, float32(EULERS_NUMBER), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_Exp2_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 Three32 = 3.0;
		float32 Exp2Zero = Math::Exp2(Zero32);
		float32 Exp2Three = Math::Exp2(Three32);
		return Math::IsNearlyEqual(Exp2Zero, float32(1.0)) && Math::IsNearlyEqual(Exp2Three, float32(8.0));
	}

	bool Observe_Loge_Nominal()
	{
		float32 One32 = 1.0;
		float32 E32 = float32(EULERS_NUMBER);
		float32 LogOne = Math::Loge(One32);
		float32 LogE = Math::Loge(E32);
		return Math::IsNearlyEqual(LogOne, float32(0.0)) && Math::IsNearlyEqual(LogE, float32(1.0), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_Log2_Nominal()
	{
		float32 Two32 = 2.0;
		float32 Eight32 = 8.0;
		float32 LogTwo = Math::Log2(Two32);
		float32 LogEight = Math::Log2(Eight32);
		return Math::IsNearlyEqual(LogTwo, float32(1.0)) && Math::IsNearlyEqual(LogEight, float32(3.0));
	}

	bool Observe_LogX_Nominal()
	{
		float32 Ten32 = 10.0;
		float32 Hundred32 = 100.0;
		float32 Two32 = 2.0;
		float32 Eight32 = 8.0;
		float32 LogTenHundred = Math::LogX(Ten32, Hundred32);
		float32 LogTwoEight = Math::LogX(Two32, Eight32);
		return Math::IsNearlyEqual(LogTenHundred, float32(2.0)) && Math::IsNearlyEqual(LogTwoEight, float32(3.0));
	}

	bool Observe_Fmod_Nominal()
	{
		float32 Five32 = 5.0;
		float32 Two32 = 2.0;
		float32 NegFive32 = -5.0;
		float32 Pos = Math::Fmod(Five32, Two32);
		float32 Neg = Math::Fmod(NegFive32, Two32);
		return Math::IsNearlyEqual(Pos, float32(1.0)) && Math::IsNearlyEqual(Neg, float32(-1.0));
	}

	bool Observe_Sin_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 HalfPi32 = float32(HALF_PI);
		float32 SinZero = Math::Sin(Zero32);
		float32 SinHalfPi = Math::Sin(HalfPi32);
		return Math::IsNearlyEqual(SinZero, float32(0.0)) && Math::IsNearlyEqual(SinHalfPi, float32(1.0), float32(KINDA_SMALL_NUMBER));
	}
}
