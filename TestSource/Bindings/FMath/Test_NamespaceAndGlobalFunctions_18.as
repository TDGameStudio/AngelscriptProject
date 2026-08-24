// Purpose: Observe remaining float64 easing curves after EaseIn.
// AS-facing API: Math::EaseOut; Math::EaseInOut; Math::SinusoidalIn;
// Math::SinusoidalOut; Math::SinusoidalInOut; Math::ExpoIn; Math::ExpoOut;
// Math::ExpoInOut; Math::CircularIn; Math::CircularOut.
// Inputs: A=0 B=10 at alpha 0/0.5/1; EaseOut/EaseInOut Exp 2.
// Expected observations: Alpha 0 returns 0 and alpha 1 returns 10. EaseOut
// midpoint is 7.5. EaseInOut midpoint is 5. Midpoints are strictly between
// A and B.
// Boundary/ownership: Alpha outside [0,1] extrapolates. Results are new
// scalars. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_18
{
	bool Observe_EaseOut_Nominal()
	{
		float64 Start = Math::EaseOut(0.0, 10.0, 0.0, 2.0);
		float64 Mid = Math::EaseOut(0.0, 10.0, 0.5, 2.0);
		float64 End = Math::EaseOut(0.0, 10.0, 1.0, 2.0);
		return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 7.5) && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_EaseInOut_Nominal()
	{
		float64 Start = Math::EaseInOut(0.0, 10.0, 0.0, 2.0);
		float64 Mid = Math::EaseInOut(0.0, 10.0, 0.5, 2.0);
		float64 End = Math::EaseInOut(0.0, 10.0, 1.0, 2.0);
		return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 5.0) && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_SinusoidalIn_Nominal()
	{
		float64 Start = Math::SinusoidalIn(0.0, 10.0, 0.0);
		float64 Mid = Math::SinusoidalIn(0.0, 10.0, 0.5);
		float64 End = Math::SinusoidalIn(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_SinusoidalOut_Nominal()
	{
		float64 Start = Math::SinusoidalOut(0.0, 10.0, 0.0);
		float64 Mid = Math::SinusoidalOut(0.0, 10.0, 0.5);
		float64 End = Math::SinusoidalOut(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_SinusoidalInOut_Nominal()
	{
		float64 Start = Math::SinusoidalInOut(0.0, 10.0, 0.0);
		float64 Mid = Math::SinusoidalInOut(0.0, 10.0, 0.5);
		float64 End = Math::SinusoidalInOut(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 5.0, KINDA_SMALL_NUMBER) && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_ExpoIn_Nominal()
	{
		float64 Start = Math::ExpoIn(0.0, 10.0, 0.0);
		float64 Mid = Math::ExpoIn(0.0, 10.0, 0.5);
		float64 End = Math::ExpoIn(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_ExpoOut_Nominal()
	{
		float64 Start = Math::ExpoOut(0.0, 10.0, 0.0);
		float64 Mid = Math::ExpoOut(0.0, 10.0, 0.5);
		float64 End = Math::ExpoOut(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_ExpoInOut_Nominal()
	{
		float64 Start = Math::ExpoInOut(0.0, 10.0, 0.0);
		float64 Mid = Math::ExpoInOut(0.0, 10.0, 0.5);
		float64 End = Math::ExpoInOut(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_CircularIn_Nominal()
	{
		float64 Start = Math::CircularIn(0.0, 10.0, 0.0);
		float64 Mid = Math::CircularIn(0.0, 10.0, 0.5);
		float64 End = Math::CircularIn(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}

	bool Observe_CircularOut_Nominal()
	{
		float64 Start = Math::CircularOut(0.0, 10.0, 0.0);
		float64 Mid = Math::CircularOut(0.0, 10.0, 0.5);
		float64 End = Math::CircularOut(0.0, 10.0, 1.0);
		return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
	}
}
