// Purpose: Observe hex formatting, RGBE decode, FromHex parse, and linear
// quantization back to FColor.
// AS-facing API: FString FColor.ToHex() const;
// FLinearColor FColor.FromRGBE() const;
// FColor FColor::FromHex(const FString& HexString);
// FColor FLinearColor.ToFColor(bool bSRGB) const;
// Inputs: FColor(255, 0, 0, 255), empty/black, hex "FF0000" and "#FF0000FF",
// invalid "not-hex", and bSRGB true/false.
// Expected observations: ToHex is an 8-digit RRGGBBAA string. FromHex of a
// valid RGB string yields red. Invalid text does not match Red. ToFColor
// returns a byte color from linear white for both sRGB flags.
// Boundary/ownership: FromHex copies hex digits; the source FString is not
// retained. ToFColor optionally applies sRGB transfer before quantization.

namespace TS_FColor_ConversionAndFormatting_01
{
	bool Observe_ToHex_Nominal()
	{
		FColor Red(255, 0, 0, 255);
		FString Hex = Red.ToHex();
		FString BlackHex = FColor::Black.ToHex();
		return Hex == "FF0000FF" && BlackHex == "000000FF";
	}

	bool Observe_FromRGBE_Nominal()
	{
		FColor Packed(128, 64, 32, 128);
		FLinearColor Decoded = Packed.FromRGBE();
		FLinearColor BlackDecoded = FColor(0, 0, 0, 0).FromRGBE();
		return Decoded.R > 0.0 && BlackDecoded.R == 0.0 && BlackDecoded.G == 0.0 && BlackDecoded.B == 0.0;
	}

	bool Observe_FromHex_Nominal()
	{
		FColor FromRgb = FColor::FromHex("FF0000");
		FColor FromPrefixed = FColor::FromHex("#FF0000FF");
		FColor Invalid = FColor::FromHex("not-hex");
		return FromRgb.R == 255 && FromRgb.G == 0 && FromRgb.B == 0 && FromRgb.A == 255 && FromPrefixed.R == 255 && FromPrefixed.A == 255 && Invalid.R == 0 && Invalid.G == 0 && Invalid.B == 0 && Invalid.A == 0;
	}

	bool Observe_ToFColor_Nominal()
	{
		FLinearColor White(1.0, 1.0, 1.0, 1.0);
		FColor WithSrgb = White.ToFColor(true);
		FColor WithoutSrgb = White.ToFColor(false);
		FLinearColor Zero(0.0, 0.0, 0.0, 0.0);
		FColor ZeroColor = Zero.ToFColor(false);
		return WithSrgb.R == 255 && WithSrgb.G == 255 && WithSrgb.B == 255 && WithoutSrgb.R == 255 && ZeroColor.R == 0 && ZeroColor.A == 0;
	}
}
