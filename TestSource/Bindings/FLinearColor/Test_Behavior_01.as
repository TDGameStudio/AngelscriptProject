// Purpose: Observe FLinearColor constructors, RGBA fields, and HSV conversion.
// AS-facing API: Color(); Color(R,G,B,A=1); Color(Other); R; G; B; A;
// LinearRGBToHSV; HSVToLinearRGB.
// Inputs: Default, (0.2,0.4,0.6) with omitted A, copy, Red for HSV round-trip.
// Expected observations: Default is black-like. Omitted A is 1. Copy preserves
// channels. HSV round-trip of Red remains reddish after HSVToLinearRGB.
// Boundary/ownership: HSV conversion returns a new color. A defaults to 1.

namespace TS_FLinearColor_Behavior_01
{
	// FLinearColor(), RGB with omitted A=1, and copy. Default R is 0. Copy keeps B.
	bool Observe_Color_Nominal()
	{
		FLinearColor DefaultColor;
		FLinearColor Rgb(0.2, 0.4, 0.6);
		FLinearColor Copied(Rgb);
		return DefaultColor.R == 0.0 && Rgb.A == 1.0 && Copied.B == 0.6;
	}

	// FLinearColor.R of (0.2,0.4,0.6,1) is 0.2. Query, no fixture.
	bool Observe_Surface004_Nominal()
	{
		return FLinearColor(0.2, 0.4, 0.6, 1.0).R == 0.2;
	}

	// FLinearColor.G of (0.2,0.4,0.6,1) is 0.4. Query, no fixture.
	bool Observe_Surface005_Nominal()
	{
		return FLinearColor(0.2, 0.4, 0.6, 1.0).G == 0.4;
	}

	// FLinearColor.B of (0.2,0.4,0.6,1) is 0.6. Query, no fixture.
	bool Observe_Surface006_Nominal()
	{
		return FLinearColor(0.2, 0.4, 0.6, 1.0).B == 0.6;
	}

	// FLinearColor.A of (0.2,0.4,0.6,0.5) is 0.5. Query, no fixture.
	bool Observe_Surface007_Nominal()
	{
		return FLinearColor(0.2, 0.4, 0.6, 0.5).A == 0.5;
	}

	// LinearRGBToHSV of Red has hue 0 with full saturation and value.
	bool Observe_LinearRGBToHSV_Nominal()
	{
		FLinearColor Hsv = FLinearColor::Red.LinearRGBToHSV();
		return Hsv.R == 0.0 && Hsv.G == 1.0 && Hsv.B == 1.0;
	}

	// HSVToLinearRGB of Red's HSV recovers a color whose R exceeds G.
	bool Observe_HSVToLinearRGB_Nominal()
	{
		FLinearColor Hsv = FLinearColor::Red.LinearRGBToHSV();
		FLinearColor RoundTrip = Hsv.HSVToLinearRGB();
		return RoundTrip.R > RoundTrip.G;
	}
}
