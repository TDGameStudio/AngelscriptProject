/**
 * @version v1
 * @summary Observe FLinearColor construction from FColor, including opaque red and transparent black.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FLinearColor construction from FColor, including opaque red and transparent black.
 * @topic Baseline
 */
// near 0. From Transparent, A is 0. Conversion does not mutate the FColor.
// Boundary/ownership: Construction converts byte channels into linear floats
// according to FColor conversion rules.

namespace TS_FLinearColor_Behavior_02
{
	bool Observe_Color_Nominal()
	{
		FLinearColor FromRed(FColor::Red);
		FLinearColor FromBlack(FColor::Black);
		FLinearColor FromTransparent(FColor::Transparent);
		return FromRed.R > FromRed.G &&
			FromBlack.R == 0.0 &&
			FromBlack.G == 0.0 &&
			FromBlack.B == 0.0 &&
			FromTransparent.A == 0.0;
	}
}
/** @end */
