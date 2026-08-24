// Purpose: Observe Math SmoothStep, inclusive Clamp across numeric widths,
// and FastAsin.
// AS-facing API: Math::SmoothStep; Math::Clamp; Math::FastAsin.
// Inputs: SmoothStep A=0 B=1 with X=-1/0/0.5/1/2; Clamp X=-1/5/15 into [0,10]
// for float64/float32/int32/uint32/int64/uint64; FastAsin 0 and 1.
// Expected observations: SmoothStep clamps to 0 below A and 1 above B; the
// midpoint is 0.5. Clamp maps -1 to 0, 5 to 5, and 15 to 10. FastAsin(0) is
// 0; FastAsin(1) is near HALF_PI.
// Boundary/ownership: Clamp is inclusive. SmoothStep X outside [A,B] saturates.
// FastAsin is an approximation. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_02
{
	bool Observe_SmoothStep_Nominal()
	{
		float64 Below64 = Math::SmoothStep(0.0, 1.0, -1.0);
		float64 Start64 = Math::SmoothStep(0.0, 1.0, 0.0);
		float64 Mid64 = Math::SmoothStep(0.0, 1.0, 0.5);
		float64 End64 = Math::SmoothStep(0.0, 1.0, 1.0);
		float64 Above64 = Math::SmoothStep(0.0, 1.0, 2.0);

		float32 A32 = 0.0;
		float32 B32 = 1.0;
		float32 BelowX32 = -1.0;
		float32 MidX32 = 0.5;
		float32 EndX32 = 1.0;
		float32 Below32 = Math::SmoothStep(A32, B32, BelowX32);
		float32 Start32 = Math::SmoothStep(A32, B32, A32);
		float32 Mid32 = Math::SmoothStep(A32, B32, MidX32);
		float32 End32 = Math::SmoothStep(A32, B32, EndX32);
		return Below64 == 0.0 && Start64 == 0.0 && Math::IsNearlyEqual(Mid64, 0.5) && End64 == 1.0 && Above64 == 1.0 &&
			Below32 == 0.0 && Start32 == 0.0 && Math::IsNearlyEqual(Mid32, float32(0.5)) && End32 == 1.0;
	}

	bool Observe_Clamp_Nominal()
	{
		float64 Low64 = Math::Clamp(-1.0, 0.0, 10.0);
		float64 Mid64 = Math::Clamp(5.0, 0.0, 10.0);
		float64 High64 = Math::Clamp(15.0, 0.0, 10.0);

		float32 Neg32 = -1.0;
		float32 MidX32 = 5.0;
		float32 HighX32 = 15.0;
		float32 Min32 = 0.0;
		float32 Max32 = 10.0;
		float32 Low32 = Math::Clamp(Neg32, Min32, Max32);
		float32 Mid32 = Math::Clamp(MidX32, Min32, Max32);
		float32 High32 = Math::Clamp(HighX32, Min32, Max32);

		int32 LowI = Math::Clamp(int32(-1), int32(0), int32(10));
		int32 MidI = Math::Clamp(int32(5), int32(0), int32(10));
		int32 HighI = Math::Clamp(int32(15), int32(0), int32(10));

		uint32 LowU = Math::Clamp(uint32(0), uint32(1), uint32(10));
		uint32 MidU = Math::Clamp(uint32(5), uint32(1), uint32(10));
		uint32 HighU = Math::Clamp(uint32(15), uint32(1), uint32(10));

		int64 Low64i = Math::Clamp(int64(-1), int64(0), int64(10));
		int64 Mid64i = Math::Clamp(int64(5), int64(0), int64(10));
		int64 High64i = Math::Clamp(int64(15), int64(0), int64(10));

		uint64 LowU64 = Math::Clamp(uint64(0), uint64(1), uint64(10));
		uint64 MidU64 = Math::Clamp(uint64(5), uint64(1), uint64(10));
		uint64 HighU64 = Math::Clamp(uint64(15), uint64(1), uint64(10));
		return Low64 == 0.0 && Mid64 == 5.0 && High64 == 10.0 &&
			Low32 == 0.0 && Mid32 == 5.0 && High32 == 10.0 &&
			LowI == 0 && MidI == 5 && HighI == 10 &&
			LowU == 1 && MidU == 5 && HighU == 10 &&
			Low64i == 0 && Mid64i == 5 && High64i == 10 &&
			LowU64 == 1 && MidU64 == 5 && HighU64 == 10;
	}

	bool Observe_FastAsin_Nominal()
	{
		float64 FastZero64 = Math::FastAsin(0.0);
		float64 FastOne64 = Math::FastAsin(1.0);
		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 FastZero32 = Math::FastAsin(Zero32);
		float32 FastOne32 = Math::FastAsin(One32);
		float32 HalfPi32 = float32(HALF_PI);
		return Math::IsNearlyEqual(FastZero64, 0.0, KINDA_SMALL_NUMBER) &&
			Math::IsNearlyEqual(FastOne64, HALF_PI, 0.01) &&
			Math::IsNearlyEqual(FastZero32, Zero32, float32(KINDA_SMALL_NUMBER)) &&
			Math::IsNearlyEqual(FastOne32, HalfPi32, float32(0.01));
	}
}
