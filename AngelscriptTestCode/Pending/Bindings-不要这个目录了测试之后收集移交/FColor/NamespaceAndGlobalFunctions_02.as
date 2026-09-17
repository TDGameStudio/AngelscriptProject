/**
 * @version v1
 * @summary Observe the remaining named FColor constants and keep a diagnostic path for an invalid hex parse used as the negative companion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe the remaining named FColor constants and keep a diagnostic path for an invalid hex parse used as the negative companion.
 * @topic Baseline
 */
// FColor FColor::Purple; FColor FColor::Turquoise; FColor FColor::Silver;
// FColor FColor::Emerald;
// Inputs: Each named constant compared against Black and against a sibling.
// Expected observations: Each constant is opaque and distinct from Black.
// Cyan has green and blue; Magenta has red and blue.
// Boundary/ownership: Named colors are shared constants. ExerciseExpectedFailure
// uses invalid hex text, which is not a named-constant lookup.

namespace TS_FColor_NamespaceAndGlobalFunctions_02
{
	// FColor::Cyan. Oracle: (0,255,255,255). Shared constant.
	bool Observe_Surface021_Nominal()
	{
		FColor Cyan = FColor::Cyan;
		return Cyan.R == 0 && Cyan.G == 255 && Cyan.B == 255 && Cyan.A == 255;
	}

	// FColor::Magenta. Oracle: (255,0,255,255). Shared constant.
	bool Observe_Surface022_Nominal()
	{
		FColor Magenta = FColor::Magenta;
		return Magenta.R == 255 && Magenta.G == 0 && Magenta.B == 255 && Magenta.A == 255;
	}

	// FColor::Orange. Oracle: (243,156,18,255). Shared constant.
	bool Observe_Surface023_Nominal()
	{
		FColor Orange = FColor::Orange;
		return Orange.R == 243 && Orange.G == 156 && Orange.B == 18 && Orange.A == 255;
	}

	// FColor::Purple. Oracle: (169,7,228,255), distinct from Red. Shared constant.
	bool Observe_Surface024_Nominal()
	{
		FColor Purple = FColor::Purple;
		return Purple.R == 169 && Purple.G == 7 && Purple.B == 228 && Purple.A == 255 && !(Purple == FColor::Red);
	}

	// FColor::Turquoise. Oracle: (26,188,156,255). Shared constant.
	bool Observe_Surface025_Nominal()
	{
		FColor Turquoise = FColor::Turquoise;
		return Turquoise.R == 26 && Turquoise.G == 188 && Turquoise.B == 156 && Turquoise.A == 255;
	}

	// FColor::Silver. Oracle: (189,195,199,255). Shared constant.
	bool Observe_Surface026_Nominal()
	{
		FColor Silver = FColor::Silver;
		return Silver.R == 189 && Silver.G == 195 && Silver.B == 199 && Silver.A == 255;
	}

	// FColor::Emerald. Oracle: (46,204,113,255) and G > R. Shared constant.
	bool Observe_Surface027_Nominal()
	{
		FColor Emerald = FColor::Emerald;
		return Emerald.R == 46 && Emerald.G == 204 && Emerald.B == 113 && Emerald.A == 255 && Emerald.G > Emerald.R;
	}

	void ExerciseExpectedFailure()
	{
		FColor Invalid = FColor::FromHex("zzzzzz");
	}
}
/** @end */
