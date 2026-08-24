// Purpose: Observe remaining float32 trig/root helpers plus Rand and FRand.
// AS-facing API: Math::Sinh; Math::Cos; Math::Acos; Math::Tan; Math::Atan;
// Math::Atan2; Math::Sqrt; Math::Pow; Math::Rand; Math::FRand.
// Inputs: Sinh(0); Cos(0)/Cos(PI); Acos(1)/Acos(0); Tan(0); Atan(1);
// Atan2(1,0); Sqrt(4); Pow(2,3); Rand and FRand samples.
// Expected observations: Float32 trig matches the float64 identities. Rand
// is nonnegative. FRand is in [0,1].
// Boundary/ownership: Random APIs are observed by range, not exact values.
// Angles are radians. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_15
{
	bool Observe_Sinh_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 SinhZero = Math::Sinh(Zero32);
		float32 SinhOne = Math::Sinh(One32);
		return Math::IsNearlyEqual(SinhZero, float32(0.0)) && SinhOne > 0.0;
	}

	bool Observe_Cos_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 Pi32 = float32(PI);
		float32 CosZero = Math::Cos(Zero32);
		float32 CosPi = Math::Cos(Pi32);
		return Math::IsNearlyEqual(CosZero, float32(1.0)) && Math::IsNearlyEqual(CosPi, float32(-1.0), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_Acos_Nominal()
	{
		float32 One32 = 1.0;
		float32 Zero32 = 0.0;
		float32 AcosOne = Math::Acos(One32);
		float32 AcosZero = Math::Acos(Zero32);
		return Math::IsNearlyEqual(AcosOne, float32(0.0)) && Math::IsNearlyEqual(AcosZero, float32(HALF_PI), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_Tan_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 Quarter32 = float32(PI / 4.0);
		float32 TanZero = Math::Tan(Zero32);
		float32 TanQuarter = Math::Tan(Quarter32);
		return Math::IsNearlyEqual(TanZero, float32(0.0)) && Math::IsNearlyEqual(TanQuarter, float32(1.0), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_Atan_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 AtanZero = Math::Atan(Zero32);
		float32 AtanOne = Math::Atan(One32);
		return Math::IsNearlyEqual(AtanZero, float32(0.0)) && Math::IsNearlyEqual(AtanOne, float32(PI / 4.0), float32(KINDA_SMALL_NUMBER));
	}

	bool Observe_Atan2_Nominal()
	{
		float32 One32 = 1.0;
		float32 Zero32 = 0.0;
		float32 Atan2Y = Math::Atan2(One32, Zero32);
		float32 Atan2X = Math::Atan2(Zero32, One32);
		return Math::IsNearlyEqual(Atan2Y, float32(HALF_PI), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(Atan2X, float32(0.0));
	}

	bool Observe_Sqrt_Nominal()
	{
		float32 Four32 = 4.0;
		float32 Zero32 = 0.0;
		float32 SqrtFour = Math::Sqrt(Four32);
		float32 SqrtZero = Math::Sqrt(Zero32);
		return Math::IsNearlyEqual(SqrtFour, float32(2.0)) && Math::IsNearlyEqual(SqrtZero, float32(0.0));
	}

	bool Observe_Pow_Nominal()
	{
		float32 Two32 = 2.0;
		float32 Three32 = 3.0;
		float32 Five32 = 5.0;
		float32 Zero32 = 0.0;
		float32 Eight = Math::Pow(Two32, Three32);
		float32 One = Math::Pow(Five32, Zero32);
		return Math::IsNearlyEqual(Eight, float32(8.0)) && Math::IsNearlyEqual(One, float32(1.0));
	}

	bool Observe_Rand_Nominal()
	{
		int32 First = Math::Rand();
		int32 Second = Math::Rand();
		return First >= 0 && Second >= 0;
	}

	bool Observe_FRand_Nominal()
	{
		float32 First = Math::FRand();
		float32 Second = Math::FRand();
		return First >= 0.0 && First <= 1.0 && Second >= 0.0 && Second <= 1.0;
	}
}
