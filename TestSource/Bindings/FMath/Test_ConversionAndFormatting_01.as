// Purpose: Observe Math arc-sine conversion for both floating widths.
// AS-facing API: Math::Asin(float64); Math::Asin(float32).
// Inputs: 0, 1, -1, and 0.5 for each width.
// Expected observations: Asin(0) is 0. Asin(1) is HALF_PI. Asin(-1) is
// -HALF_PI. Asin(0.5) is positive and less than HALF_PI.
// Boundary/ownership: Results are radians. Domain is [-1, 1]. Call Math::,
// never FMath::.

namespace TS_FMath_ConversionAndFormatting_01
{
	bool Observe_Asin_Nominal()
	{
		float64 AsinZero64 = Math::Asin(0.0);
		float64 AsinOne64 = Math::Asin(1.0);
		float64 AsinNeg64 = Math::Asin(-1.0);
		float64 AsinHalf64 = Math::Asin(0.5);
		bool bAsin64 = Math::IsNearlyEqual(AsinZero64, 0.0) &&
			Math::IsNearlyEqual(AsinOne64, HALF_PI, KINDA_SMALL_NUMBER) &&
			Math::IsNearlyEqual(AsinNeg64, -HALF_PI, KINDA_SMALL_NUMBER) &&
			AsinHalf64 > 0.0 &&
			AsinHalf64 < HALF_PI;

		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 Neg32 = -1.0;
		float32 Half32 = 0.5;
		float32 AsinZero32 = Math::Asin(Zero32);
		float32 AsinOne32 = Math::Asin(One32);
		float32 AsinNeg32 = Math::Asin(Neg32);
		float32 AsinHalf32 = Math::Asin(Half32);
		float32 HalfPi32 = float32(HALF_PI);
		bool bAsin32 = Math::IsNearlyEqual(AsinZero32, Zero32) &&
			Math::IsNearlyEqual(AsinOne32, HalfPi32, float32(KINDA_SMALL_NUMBER)) &&
			Math::IsNearlyEqual(AsinNeg32, -HalfPi32, float32(KINDA_SMALL_NUMBER)) &&
			AsinHalf32 > 0.0 &&
			AsinHalf32 < HalfPi32;
		return bAsin64 && bAsin32;
	}
}
