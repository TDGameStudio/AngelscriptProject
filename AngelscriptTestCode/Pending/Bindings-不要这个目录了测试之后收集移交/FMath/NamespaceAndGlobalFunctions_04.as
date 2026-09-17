/**
 * @version v1
 * @summary Observe Math scalar, vector, and linear-color Lerp plus VLerp per-axis interpolation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Math scalar, vector, and linear-color Lerp plus VLerp per-axis interpolation.
 * @topic Baseline
 */
// (0,0)-(10,10); FVector3f and FVector2f at float32 alpha 0.5; VLerp alpha
// (0, 0.5, 1); White-to-Black at 0.5.
// Expected observations: Alpha 0 returns A, 1 returns B, 0.5 is the midpoint,
// 2 extrapolates to 20. VLerp X stays A, Y is the midpoint, Z is B.
// Boundary/ownership: Alpha outside [0,1] extrapolates. Call Math::. Results
// are new values; endpoints are not mutated.

namespace TS_FMath_NamespaceAndGlobalFunctions_04
{
	bool Observe_LerpStable_Nominal()
	{
		float64 Start64 = Math::LerpStable(0.0, 10.0, 0.0);
		float64 Mid64 = Math::LerpStable(0.0, 10.0, 0.5);
		float64 End64 = Math::LerpStable(0.0, 10.0, 1.0);
		float64 Extra64 = Math::LerpStable(0.0, 10.0, 2.0);

		float32 A32 = 0.0;
		float32 B32 = 10.0;
		float32 Zero32 = 0.0;
		float32 Half32 = 0.5;
		float32 One32 = 1.0;
		float32 Two32 = 2.0;
		float32 Start32 = Math::LerpStable(A32, B32, Zero32);
		float32 Mid32 = Math::LerpStable(A32, B32, Half32);
		float32 End32 = Math::LerpStable(A32, B32, One32);
		float32 Extra32 = Math::LerpStable(A32, B32, Two32);
		return Start64 == 0.0 && Mid64 == 5.0 && End64 == 10.0 && Extra64 == 20.0 && Start32 == 0.0 && Mid32 == 5.0 && End32 == 10.0 && Extra32 == 20.0;
	}

	bool Observe_Lerp_Nominal()
	{
		float64 Start64 = Math::Lerp(0.0, 10.0, 0.0);
		float64 Mid64 = Math::Lerp(0.0, 10.0, 0.5);
		float64 End64 = Math::Lerp(0.0, 10.0, 1.0);
		float64 Extra64 = Math::Lerp(0.0, 10.0, 2.0);

		float32 A32 = 0.0;
		float32 B32 = 10.0;
		float32 Zero32 = 0.0;
		float32 Half32 = 0.5;
		float32 One32 = 1.0;
		float32 Start32 = Math::Lerp(A32, B32, Zero32);
		float32 Mid32 = Math::Lerp(A32, B32, Half32);
		float32 End32 = Math::Lerp(A32, B32, One32);

		FVector FromV(0.0, 0.0, 0.0);
		FVector ToV(10.0, 0.0, 0.0);
		FVector MidV = Math::Lerp(FromV, ToV, 0.5);
		FVector StartV = Math::Lerp(FromV, ToV, 0.0);

		FVector2D From2D(0.0, 0.0);
		FVector2D To2D(10.0, 10.0);
		FVector2D Mid2D = Math::Lerp(From2D, To2D, 0.5);

		FVector3f From3f(0.0, 0.0, 0.0);
		FVector3f To3f(10.0, 0.0, 0.0);
		FVector3f Mid3f = Math::Lerp(From3f, To3f, Half32);

		FVector2f From2f(0.0, 0.0);
		FVector2f To2f(10.0, 10.0);
		FVector2f Mid2f = Math::Lerp(From2f, To2f, Half32);

		FLinearColor MidColor = Math::Lerp(FLinearColor::White, FLinearColor::Black, Half32);
		bool bScalar = Start64 == 0.0 && Mid64 == 5.0 && End64 == 10.0 && Extra64 == 20.0 && Start32 == 0.0 && Mid32 == 5.0 && End32 == 10.0;
		bool bVector = MidV.X == 5.0 && StartV.X == 0.0 && Mid2D.X == 5.0 && Mid3f.X == 5.0 && Mid2f.X == 5.0;
		bool bColor = MidColor.R > 0.0 && MidColor.R < 1.0;
		return bScalar && bVector && bColor;
	}

	bool Observe_VLerp_Nominal()
	{
		FVector From(0.0, 0.0, 0.0);
		FVector To(10.0, 20.0, 30.0);
		FVector Alpha(0.0, 0.5, 1.0);
		FVector Mixed = Math::VLerp(From, To, Alpha);
		FVector ZeroAlpha = Math::VLerp(From, To, FVector(0.0, 0.0, 0.0));
		bool bPerAxis = Mixed.X == 0.0 && Mixed.Y == 10.0 && Mixed.Z == 30.0;
		bool bZeroStaysFrom = ZeroAlpha.X == 0.0 && ZeroAlpha.Y == 0.0 && ZeroAlpha.Z == 0.0;
		return bPerAxis && bZeroStaysFrom;
	}
}
/** @end */
