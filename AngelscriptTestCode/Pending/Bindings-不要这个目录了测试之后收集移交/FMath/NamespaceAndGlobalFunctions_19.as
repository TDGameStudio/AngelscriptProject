/**
 * @version v1
 * @summary Observe float64 CircularInOut and the float32 easing family.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe float64 CircularInOut and the float32 easing family.
 * @topic Baseline
 */
// Math::EaseInOut; Math::SinusoidalIn; Math::SinusoidalOut;
// Math::SinusoidalInOut; Math::ExpoIn; Math::ExpoOut; Math::ExpoInOut.
// Inputs: A=0 B=10 at alpha 0/0.5/1; Ease* Exp 2; typed float32 locals.
// Expected observations: Endpoints are A and B. EaseIn midpoint is 2.5.
// EaseOut midpoint is 7.5. EaseInOut midpoint is 5. Other midpoints lie
// strictly between A and B.
// Boundary/ownership: Overloads are selected by float32 locals. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_19
{
	bool Observe_CircularInOut_Nominal()
	{
		float64 Start = Math::CircularInOut(0.0, 10.0, 0.0);
		float64 Mid = Math::CircularInOut(0.0, 10.0, 0.5);
		float64 End = Math::CircularInOut(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 5.0, KINDA_SMALL_NUMBER) && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_EaseIn_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Exp = 2.0;
		float32 Start = Math::EaseIn(A, B, Zero, Exp);
		float32 Mid = Math::EaseIn(A, B, Half, Exp);
		float32 End = Math::EaseIn(A, B, One, Exp);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(2.5)) && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_EaseOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Exp = 2.0;
		float32 Start = Math::EaseOut(A, B, Zero, Exp);
		float32 Mid = Math::EaseOut(A, B, Half, Exp);
		float32 End = Math::EaseOut(A, B, One, Exp);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(7.5)) && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_EaseInOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Exp = 2.0;
		float32 Start = Math::EaseInOut(A, B, Zero, Exp);
		float32 Mid = Math::EaseInOut(A, B, Half, Exp);
		float32 End = Math::EaseInOut(A, B, One, Exp);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(5.0)) && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_SinusoidalIn_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::SinusoidalIn(A, B, Zero);
		float32 Mid = Math::SinusoidalIn(A, B, Half);
		float32 End = Math::SinusoidalIn(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_SinusoidalOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::SinusoidalOut(A, B, Zero);
		float32 Mid = Math::SinusoidalOut(A, B, Half);
		float32 End = Math::SinusoidalOut(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_SinusoidalInOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::SinusoidalInOut(A, B, Zero);
		float32 Mid = Math::SinusoidalInOut(A, B, Half);
		float32 End = Math::SinusoidalInOut(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(5.0), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_ExpoIn_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::ExpoIn(A, B, Zero);
		float32 Mid = Math::ExpoIn(A, B, Half);
		float32 End = Math::ExpoIn(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_ExpoOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::ExpoOut(A, B, Zero);
		float32 Mid = Math::ExpoOut(A, B, Half);
		float32 End = Math::ExpoOut(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_ExpoInOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::ExpoInOut(A, B, Zero);
		float32 Mid = Math::ExpoInOut(A, B, Half);
		float32 End = Math::ExpoInOut(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}
}
/** @end */
