/**
 * @version v1
 * @summary Observe float64 logarithms, remainder, and trigonometric helpers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe float64 logarithms, remainder, and trigonometric helpers.
 * @topic Baseline
 */
// Math::Sinh; Math::Cos; Math::Acos; Math::Tan; Math::Atan.
// Inputs: Loge(1) and Loge(EULERS_NUMBER); Log2(8); LogX(10, 100); Fmod(5,2)
// and Fmod(-5,2); Sin/Cos of 0 and HALF_PI; Acos(1) and Acos(0); Tan(0);
// Atan(0).
// Expected observations: Loge(1) is 0. Log2(8) is 3. LogX(10,100) is 2.
// Fmod(5,2) is 1. Sin(0) is 0 and Cos(0) is 1. Acos(1) is 0. Tan(0) and
// Atan(0) are 0.
// Boundary/ownership: Log Value is positive. Fmod Y is a nonzero divisor.
// Angles are radians. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_13
{
	bool Observe_Loge_Nominal()
	{
		float64 LogOne = Math::Loge(1.0);
		float64 LogE = Math::Loge(EULERS_NUMBER);
		return Math::IsNearlyEqual(LogOne, 0.0) && Math::IsNearlyEqual(LogE, 1.0, KINDA_SMALL_NUMBER);
	}

	bool Observe_Log2_Nominal()
	{
		float64 LogTwo = Math::Log2(2.0);
		float64 LogEight = Math::Log2(8.0);
		return Math::IsNearlyEqual(LogTwo, 1.0) && Math::IsNearlyEqual(LogEight, 3.0);
	}

	bool Observe_LogX_Nominal()
	{
		float64 LogTenHundred = Math::LogX(10.0, 100.0);
		float64 LogTwoEight = Math::LogX(2.0, 8.0);
		return Math::IsNearlyEqual(LogTenHundred, 2.0) && Math::IsNearlyEqual(LogTwoEight, 3.0);
	}

	bool Observe_Fmod_Nominal()
	{
		float64 Pos = Math::Fmod(5.0, 2.0);
		float64 Neg = Math::Fmod(-5.0, 2.0);
		float64 Whole = Math::Fmod(6.0, 2.0);
		return Math::IsNearlyEqual(Pos, 1.0) && Math::IsNearlyEqual(Neg, -1.0) && Math::IsNearlyEqual(Whole, 0.0);
	}

	bool Observe_Sin_Nominal()
	{
		float64 SinZero = Math::Sin(0.0);
		float64 SinHalfPi = Math::Sin(HALF_PI);
		return Math::IsNearlyEqual(SinZero, 0.0) && Math::IsNearlyEqual(SinHalfPi, 1.0);
	}

	bool Observe_Sinh_Nominal()
	{
		float64 SinhZero = Math::Sinh(0.0);
		float64 SinhOne = Math::Sinh(1.0);
		return Math::IsNearlyEqual(SinhZero, 0.0) && SinhOne > 0.0;
	}

	bool Observe_Cos_Nominal()
	{
		float64 CosZero = Math::Cos(0.0);
		float64 CosPi = Math::Cos(PI);
		return Math::IsNearlyEqual(CosZero, 1.0) && Math::IsNearlyEqual(CosPi, -1.0);
	}

	bool Observe_Acos_Nominal()
	{
		float64 AcosOne = Math::Acos(1.0);
		float64 AcosZero = Math::Acos(0.0);
		return Math::IsNearlyEqual(AcosOne, 0.0) && Math::IsNearlyEqual(AcosZero, HALF_PI);
	}

	bool Observe_Tan_Nominal()
	{
		float64 TanZero = Math::Tan(0.0);
		float64 TanQuarter = Math::Tan(PI / 4.0);
		return Math::IsNearlyEqual(TanZero, 0.0) && Math::IsNearlyEqual(TanQuarter, 1.0, KINDA_SMALL_NUMBER);
	}

	bool Observe_Atan_Nominal()
	{
		float64 AtanZero = Math::Atan(0.0);
		float64 AtanOne = Math::Atan(1.0);
		return Math::IsNearlyEqual(AtanZero, 0.0) && Math::IsNearlyEqual(AtanOne, PI / 4.0);
	}
}
/** @end */
