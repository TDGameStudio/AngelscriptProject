// Theme: Gameplay.FLinearColor. Positive ToFColor / luminance / HSV lerp oracles.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorMethods
// Oracle: ToFColor(true) White RGBA 255; ToFColor(false) R 255; GetLuminance White > 0.9;
// LerpUsingHSV(Black, White, 0.5) R in (0,1).
// Extra: default Black luminance 0; lerp inputs copy-independent. DefaultSafe.

FColor ToFColorSRGB()
{
	FLinearColor c = FLinearColor::White;
	return c.ToFColor(true);
}

FColor ToFColorLinear()
{
	FLinearColor c = FLinearColor(1.0, 0.5, 0.0, 1.0);
	return c.ToFColor(false);
}

float GetLuminance()
{
	FLinearColor c = FLinearColor::White;
	return c.GetLuminance();
}

FLinearColor LerpColors()
{
	FLinearColor a = FLinearColor::Black;
	FLinearColor b = FLinearColor::White;
	return FLinearColor::LerpUsingHSV(a, b, 0.5);
}

bool Observe_ToFColorSRGB()
{
	FColor Result = ToFColorSRGB();
	return Result.R == 255 && Result.G == 255 && Result.B == 255 && Result.A == 255;
}

bool Observe_ToFColorLinear_R()
{
	FColor Result = ToFColorLinear();
	return Result.R == 255;
}

bool Observe_GetLuminance_White()
{
	return GetLuminance() > 0.9;
}

bool Observe_LerpColors_Intermediate()
{
	FLinearColor Result = LerpColors();
	return Result.R > 0.0 && Result.R < 1.0;
}

bool Observe_GetLuminance_DefaultBlack()
{
	FLinearColor Empty = FLinearColor();
	return Empty.GetLuminance() == 0.0;
}

bool Observe_LerpColors_CopyIndependence()
{
	FLinearColor A = FLinearColor::Black;
	FLinearColor B = FLinearColor::White;
	FLinearColor Mid = FLinearColor::LerpUsingHSV(A, B, 0.5);
	Mid.R = 0.0;
	return A.Equals(FLinearColor::Black) && B.Equals(FLinearColor::White);
}
