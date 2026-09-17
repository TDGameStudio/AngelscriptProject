/**
 * @version v1
 * @summary Observe Math degree/radian conversion, wrapped ClampAngle, and Unwind into signed ranges.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Math degree/radian conversion, wrapped ClampAngle, and Unwind into signed ranges.
 * @topic Baseline
 */
// Math::ClampAngle; Math::UnwindDegrees; Math::UnwindRadians.
// Inputs: PI and 180; 0 and 90 inside [-45,45]; 270 and -270 degrees;
// 3*PI radians; both float64 and float32 overloads.
// Expected observations: PI maps to 180 degrees and 180 maps to PI.
// ClampAngle(0) stays 0. UnwindDegrees(270) is -90. UnwindRadians of a
// wrapped angle stays in [-PI, PI].
// Boundary/ownership: Unwind ranges are +/-180 degrees and +/-PI radians.
// ClampAngle uses wrapped degree bounds. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_03
{
	bool Observe_RadiansToDegrees_Nominal()
	{
		float64 Deg64 = Math::RadiansToDegrees(PI);
		float64 Zero64 = Math::RadiansToDegrees(0.0);
		float32 Pi32 = float32(PI);
		float32 Zero32 = 0.0;
		float32 Deg32 = Math::RadiansToDegrees(Pi32);
		float32 ZeroDeg32 = Math::RadiansToDegrees(Zero32);
		return Math::IsNearlyEqual(Deg64, 180.0) &&
			Zero64 == 0.0 &&
			Math::IsNearlyEqual(Deg32, float32(180.0), float32(KINDA_SMALL_NUMBER)) &&
			ZeroDeg32 == 0.0;
	}

	bool Observe_DegreesToRadians_Nominal()
	{
		float64 Rad64 = Math::DegreesToRadians(180.0);
		float64 Zero64 = Math::DegreesToRadians(0.0);
		float32 Deg32 = 180.0;
		float32 Zero32 = 0.0;
		float32 Rad32 = Math::DegreesToRadians(Deg32);
		float32 ZeroRad32 = Math::DegreesToRadians(Zero32);
		return Math::IsNearlyEqual(Rad64, PI) &&
			Zero64 == 0.0 &&
			Math::IsNearlyEqual(Rad32, float32(PI), float32(KINDA_SMALL_NUMBER)) &&
			ZeroRad32 == 0.0;
	}

	bool Observe_ClampAngle_Nominal()
	{
		float32 Angle32 = 0.0;
		float32 Min32 = -45.0;
		float32 Max32 = 45.0;
		float32 Inside32 = Math::ClampAngle(Angle32, Min32, Max32);
		float32 Wide32 = Math::ClampAngle(float32(90.0), Min32, Max32);
		float64 Inside64 = Math::ClampAngle(0.0, -45.0, 45.0);
		float64 Wide64 = Math::ClampAngle(90.0, -45.0, 45.0);
		return Math::IsNearlyEqual(Inside32, float32(0.0)) &&
			Wide32 >= -45.0 && Wide32 <= 45.0 &&
			Math::IsNearlyEqual(Inside64, 0.0) &&
			Wide64 >= -45.0 && Wide64 <= 45.0;
	}

	bool Observe_UnwindDegrees_Nominal()
	{
		float64 Unwound64 = Math::UnwindDegrees(270.0);
		float64 Negative64 = Math::UnwindDegrees(-270.0);
		float64 Small64 = Math::UnwindDegrees(45.0);
		float32 Unwound32 = Math::UnwindDegrees(float32(270.0));
		float32 Negative32 = Math::UnwindDegrees(float32(-270.0));
		float32 Small32 = Math::UnwindDegrees(float32(45.0));
		return Math::IsNearlyEqual(Unwound64, -90.0) &&
			Math::IsNearlyEqual(Negative64, 90.0) &&
			Math::IsNearlyEqual(Small64, 45.0) &&
			Math::IsNearlyEqual(Unwound32, float32(-90.0)) &&
			Math::IsNearlyEqual(Negative32, float32(90.0)) &&
			Math::IsNearlyEqual(Small32, float32(45.0));
	}

	bool Observe_UnwindRadians_Nominal()
	{
		float64 Unwound64 = Math::UnwindRadians(3.0 * PI);
		float64 Small64 = Math::UnwindRadians(HALF_PI);
		float32 ThreePi32 = float32(3.0 * PI);
		float32 HalfPi32 = float32(HALF_PI);
		float32 Unwound32 = Math::UnwindRadians(ThreePi32);
		float32 Small32 = Math::UnwindRadians(HalfPi32);
		return Unwound64 >= -PI && Unwound64 <= PI &&
			Math::IsNearlyEqual(Small64, HALF_PI) &&
			Unwound32 >= -float32(PI) && Unwound32 <= float32(PI) &&
			Math::IsNearlyEqual(Small32, HalfPi32, float32(KINDA_SMALL_NUMBER));
	}
}
/** @end */
