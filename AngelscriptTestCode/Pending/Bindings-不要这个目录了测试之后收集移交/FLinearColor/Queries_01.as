/**
 * @version v1
 * @summary Observe clamp, tolerant equality, almost-black, min/max channel, and luminance queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe clamp, tolerant equality, almost-black, min/max channel, and luminance queries.
 * @topic Baseline
 */
// almost black; White is not. GetMin of the sample is -0.2 before clamp.
// White luminance is greater than Black.
// Boundary/ownership: GetClamped returns a new color. Equals uses tolerance.

namespace TS_FLinearColor_Queries_01
{
	bool Observe_GetClamped_Nominal()
	{
		FLinearColor Color(1.5, -0.2, 0.4, 1.0);
		FLinearColor Clamped = Color.GetClamped();
		FLinearColor Custom = Color.GetClamped(0.0, 0.5);
		return Clamped.R == 1.0 && Clamped.G == 0.0 && Custom.R == 0.5;
	}

	bool Observe_Equals_Nominal()
	{
		FLinearColor Left(0.2, 0.4, 0.6, 1.0);
		FLinearColor Right(0.2, 0.4, 0.6, 1.0);
		FLinearColor Perturbed(0.2 + KINDA_SMALL_NUMBER * 0.5, 0.4, 0.6, 1.0);
		return Left.Equals(Right) && Left.Equals(Perturbed);
	}

	bool Observe_IsAlmostBlack_Nominal()
	{
		return FLinearColor::Black.IsAlmostBlack() && !FLinearColor::White.IsAlmostBlack();
	}

	bool Observe_GetMin_Nominal()
	{
		FLinearColor Color(0.2, 0.4, 0.1, 1.0);
		return Color.GetMin() == 0.1;
	}

	bool Observe_GetMax_Nominal()
	{
		FLinearColor Color(0.2, 0.4, 0.1, 1.0);
		return Color.GetMax() == 0.4;
	}

	bool Observe_GetLuminance_Nominal()
	{
		float32 WhiteLum = FLinearColor::White.GetLuminance();
		float32 BlackLum = FLinearColor::Black.GetLuminance();
		return WhiteLum > BlackLum && BlackLum == 0.0;
	}
}
/** @end */
