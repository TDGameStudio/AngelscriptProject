// Purpose: Observe FLinearColor factories and the first palette constants.
// AS-facing API: MakeRandomColor; MakeFromColorTemperature; MakeFromHSV8;
// LerpUsingHSV; MakeFromHex; White; Gray; Black; Transparent; Red.
// Inputs: Temp 6500, HSV (0,255,255), Progress 0/0.5/1, Hex 0xFF0000, bSRGB
// true/false.
// Expected observations: Random color A is 1. HSV red has R > G. Lerp 0
// matches From. White.R is 1. Transparent.A is 0. Black is almost black.
// Boundary/ownership: Palette constants are shared values. Hex is a packed
// uint32.

namespace TS_FLinearColor_NamespaceAndGlobalFunctions_01
{
	// FLinearColor::MakeRandomColor is opaque with RGB in [0,1]. Random range check.
	bool Observe_MakeRandomColor_Nominal()
	{
		FLinearColor Random = FLinearColor::MakeRandomColor();
		return Random.A == 1.0 &&
			Random.R >= 0.0 && Random.R <= 1.0 &&
			Random.G >= 0.0 && Random.G <= 1.0 &&
			Random.B >= 0.0 && Random.B <= 1.0;
	}

	// MakeFromColorTemperature(6500) and (2000) stay opaque with non-negative red.
	bool Observe_MakeFromColorTemperature_Nominal()
	{
		FLinearColor Daylight = FLinearColor::MakeFromColorTemperature(6500.0);
		FLinearColor Warm = FLinearColor::MakeFromColorTemperature(2000.0);
		return Daylight.A == 1.0 && Warm.R >= 0.0 && Warm.A == 1.0;
	}

	// MakeFromHSV8(0,255,255) is red-dominant; (0,0,0) is almost black.
	bool Observe_MakeFromHSV8_Nominal()
	{
		FLinearColor Red = FLinearColor::MakeFromHSV8(0, 255, 255);
		FLinearColor Black = FLinearColor::MakeFromHSV8(0, 0, 0);
		return Red.R > Red.G && Black.IsAlmostBlack();
	}

	// LerpUsingHSV at 0 matches From, at 1 matches To, midpoint G is non-negative.
	bool Observe_LerpUsingHSV_Nominal()
	{
		FLinearColor From = FLinearColor::Red;
		FLinearColor To = FLinearColor::Blue;
		FLinearColor Start = FLinearColor::LerpUsingHSV(From, To, 0.0);
		FLinearColor Mid = FLinearColor::LerpUsingHSV(From, To, 0.5);
		FLinearColor End = FLinearColor::LerpUsingHSV(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To) && Mid.G >= 0.0;
	}

	// MakeFromHex(0xFF0000) has R>0 for sRGB and linear; hex 0 is R=0.
	bool Observe_MakeFromHex_Nominal()
	{
		FLinearColor Srgb = FLinearColor::MakeFromHex(0xFF0000);
		FLinearColor Linear = FLinearColor::MakeFromHex(0xFF0000, false);
		FLinearColor Zero = FLinearColor::MakeFromHex(0);
		return Srgb.R > 0.0 && Linear.R > 0.0 && Zero.R == 0.0;
	}

	// FLinearColor::White is (1,1,1,1). Palette constant.
	bool Observe_Surface035_Nominal()
	{
		return FLinearColor::White.R == 1.0 && FLinearColor::White.A == 1.0;
	}

	// FLinearColor::Gray R is strictly between 0 and 1. Palette constant.
	bool Observe_Surface036_Nominal()
	{
		return FLinearColor::Gray.R > 0.0 && FLinearColor::Gray.R < 1.0;
	}

	// FLinearColor::Black is (0,*,*,1). Palette constant.
	bool Observe_Surface037_Nominal()
	{
		return FLinearColor::Black.R == 0.0 && FLinearColor::Black.A == 1.0;
	}

	// FLinearColor::Transparent has A=0. Palette constant.
	bool Observe_Surface038_Nominal()
	{
		return FLinearColor::Transparent.A == 0.0;
	}

	// FLinearColor::Red has R>G and A=1. Palette constant.
	bool Observe_Surface039_Nominal()
	{
		return FLinearColor::Red.R > FLinearColor::Red.G && FLinearColor::Red.A == 1.0;
	}
}
