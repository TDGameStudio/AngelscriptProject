/**
 * @version v1
 * @summary Observe remaining float32 circular easings and FVector Ease/Sinusoidal/ExpoIn.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining float32 circular easings and FVector Ease/Sinusoidal/ExpoIn.
 * @topic Baseline
 */
// Math::EaseIn; Math::EaseOut; Math::EaseInOut; Math::SinusoidalIn;
// Math::SinusoidalOut; Math::SinusoidalInOut; Math::ExpoIn.
// Inputs: float32 0-to-10 circular family; FVector (0,0,0) to (10,0,0) at
// alpha 0/0.5/1 with Ease Exp 2.
// Expected observations: Endpoints match A and B. Vector EaseIn midpoint X
// is 2.5. Vector EaseOut midpoint X is 7.5. Vector EaseInOut midpoint X is
// 5. Other midpoints lie strictly between the endpoints.
// Boundary/ownership: Vector overloads take float32 Alpha. Results are new
// values. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_20
{
	bool Observe_CircularIn_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::CircularIn(A, B, Zero);
		float32 Mid = Math::CircularIn(A, B, Half);
		float32 End = Math::CircularIn(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_CircularOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::CircularOut(A, B, Zero);
		float32 Mid = Math::CircularOut(A, B, Half);
		float32 End = Math::CircularOut(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_CircularInOut_Nominal()
	{
		float32 A = 0.0;
		float32 B = 10.0;
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Start = Math::CircularInOut(A, B, Zero);
		float32 Mid = Math::CircularInOut(A, B, Half);
		float32 End = Math::CircularInOut(A, B, One);
		return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(5.0), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(End, float32(10.0));
	}

	bool Observe_EaseIn_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Exp = 2.0;
		FVector Start = Math::EaseIn(A, B, Zero, Exp);
		FVector Mid = Math::EaseIn(A, B, Half, Exp);
		FVector End = Math::EaseIn(A, B, One, Exp);
		return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 2.5) && End.Equals(B);
	}

	bool Observe_EaseOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Exp = 2.0;
		FVector Start = Math::EaseOut(A, B, Zero, Exp);
		FVector Mid = Math::EaseOut(A, B, Half, Exp);
		FVector End = Math::EaseOut(A, B, One, Exp);
		return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 7.5) && End.Equals(B);
	}

	bool Observe_EaseInOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		float32 Exp = 2.0;
		FVector Start = Math::EaseInOut(A, B, Zero, Exp);
		FVector Mid = Math::EaseInOut(A, B, Half, Exp);
		FVector End = Math::EaseInOut(A, B, One, Exp);
		return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 5.0) && End.Equals(B);
	}

	bool Observe_SinusoidalIn_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::SinusoidalIn(A, B, Zero);
		FVector Mid = Math::SinusoidalIn(A, B, Half);
		FVector End = Math::SinusoidalIn(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}

	bool Observe_SinusoidalOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::SinusoidalOut(A, B, Zero);
		FVector Mid = Math::SinusoidalOut(A, B, Half);
		FVector End = Math::SinusoidalOut(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}

	bool Observe_SinusoidalInOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::SinusoidalInOut(A, B, Zero);
		FVector Mid = Math::SinusoidalInOut(A, B, Half);
		FVector End = Math::SinusoidalInOut(A, B, One);
		return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 5.0, KINDA_SMALL_NUMBER) && End.Equals(B);
	}

	bool Observe_ExpoIn_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::ExpoIn(A, B, Zero);
		FVector Mid = Math::ExpoIn(A, B, Half);
		FVector End = Math::ExpoIn(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}
}
/** @end */
