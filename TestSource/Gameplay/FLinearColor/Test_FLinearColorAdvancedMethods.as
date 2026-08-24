// Theme: Gameplay.FLinearColor. Positive advanced method oracles.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::FLinearColorAdvancedMethods
// Oracle: Clamp (-0.5,0.25,1.5,2.0)->(0,0.25,1,1); EqualsWithinTolerance true;
// AlmostBlack true; Min 0.2; Max 0.9; HSV round-trip (0.25,0.5,0.75,1);
// MakeFromHex true/false opaque white; FLinearColor(FColor red) R>0.99 G/B<0.01;
// ReinterpretAsLinear green G>0.99.
// Extra: default IsAlmostBlack; copy independence of ClampColor. DefaultSafe.

FLinearColor ClampColor()
{
	FLinearColor c = FLinearColor(-0.5, 0.25, 1.5, 2.0);
	return c.GetClamped(0.0, 1.0);
}

bool EqualsWithinTolerance()
{
	FLinearColor a = FLinearColor(0.2, 0.4, 0.6, 1.0);
	FLinearColor b = FLinearColor(0.201, 0.399, 0.6, 1.0);
	return a.Equals(b, 0.01);
}

bool AlmostBlack()
{
	FLinearColor c = FLinearColor(0.0, 0.0, 0.0, 1.0);
	return c.IsAlmostBlack();
}

float MinComponent()
{
	FLinearColor c = FLinearColor(0.6, 0.2, 0.9, 0.4);
	return c.GetMin();
}

float MaxComponent()
{
	FLinearColor c = FLinearColor(0.6, 0.2, 0.9, 0.4);
	return c.GetMax();
}

FLinearColor RoundTripHSV()
{
	FLinearColor c = FLinearColor(0.25, 0.5, 0.75, 1.0);
	return c.LinearRGBToHSV().HSVToLinearRGB();
}

FLinearColor MakeHexSRGB()
{
	return FLinearColor::MakeFromHex(0xFFFFFFFF, true);
}

FLinearColor MakeHexLinear()
{
	return FLinearColor::MakeFromHex(0xFFFFFFFF, false);
}

FLinearColor ConstructFromFColor()
{
	FColor c = FColor(255, 0, 0, 255);
	return FLinearColor(c);
}

FLinearColor ReinterpretFromFColor()
{
	FColor c = FColor(0, 255, 0, 255);
	return c.ReinterpretAsLinear();
}

bool Observe_ClampColor()
{
	return ClampColor().Equals(FLinearColor(0.0, 0.25, 1.0, 1.0));
}

bool Observe_EqualsWithinTolerance()
{
	return EqualsWithinTolerance() == true;
}

bool Observe_AlmostBlack()
{
	return AlmostBlack() == true;
}

bool Observe_MinComponent()
{
	return MinComponent() == 0.2;
}

bool Observe_MaxComponent()
{
	return MaxComponent() == 0.9;
}

bool Observe_RoundTripHSV()
{
	return RoundTripHSV().Equals(FLinearColor(0.25, 0.5, 0.75, 1.0), 0.01);
}

bool Observe_MakeHexSRGB_OpaqueWhite()
{
	FLinearColor Result = MakeHexSRGB();
	return Result.R > 0.99 && Result.G > 0.99 && Result.B > 0.99 && Result.A > 0.99;
}

bool Observe_MakeHexLinear_OpaqueWhite()
{
	FLinearColor Result = MakeHexLinear();
	return Result.R > 0.99 && Result.G > 0.99 && Result.B > 0.99 && Result.A > 0.99;
}

bool Observe_ConstructFromFColor_OpaqueRed()
{
	FLinearColor Result = ConstructFromFColor();
	return Result.R > 0.99 && Result.G < 0.01 && Result.B < 0.01 && Result.A > 0.99;
}

bool Observe_ReinterpretFromFColor_OpaqueGreen()
{
	FLinearColor Result = ReinterpretFromFColor();
	return Result.G > 0.99 && Result.R < 0.01 && Result.B < 0.01 && Result.A > 0.99;
}

bool Observe_AlmostBlack_DefaultEmpty()
{
	return FLinearColor().IsAlmostBlack() == true;
}

bool Observe_ClampColor_CopyIndependence()
{
	FLinearColor Source = FLinearColor(-0.5, 0.25, 1.5, 2.0);
	FLinearColor Clamped = Source.GetClamped(0.0, 1.0);
	Clamped.R = 1.0;
	return Source.R == -0.5 && Source.A == 2.0;
}
