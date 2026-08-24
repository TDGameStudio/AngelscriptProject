// Theme: Gameplay.FLinearColor. Positive construction oracles.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorConstruction
// Oracle: default (0,0,0,1); four-param (0.5,0.6,0.7,0.8); three-param alpha 1;
// White/Black/Red/Green/Blue/Yellow named colors.
// Extra: default empty vector; copy independence of four-param. DefaultSafe.

FLinearColor ConstructDefault()
{
	return FLinearColor();
}

FLinearColor ConstructFourParams()
{
	return FLinearColor(0.5, 0.6, 0.7, 0.8);
}

FLinearColor ConstructThreeParams()
{
	return FLinearColor(0.2, 0.4, 0.6);
}

FLinearColor ConstructWhite()
{
	return FLinearColor::White;
}

FLinearColor ConstructBlack()
{
	return FLinearColor::Black;
}

FLinearColor ConstructRed()
{
	return FLinearColor::Red;
}

FLinearColor ConstructGreen()
{
	return FLinearColor::Green;
}

FLinearColor ConstructBlue()
{
	return FLinearColor::Blue;
}

FLinearColor ConstructYellow()
{
	return FLinearColor::Yellow;
}

bool Observe_ConstructDefault()
{
	return ConstructDefault().Equals(FLinearColor(0.0, 0.0, 0.0, 1.0));
}

bool Observe_ConstructFourParams()
{
	return ConstructFourParams().Equals(FLinearColor(0.5, 0.6, 0.7, 0.8));
}

bool Observe_ConstructThreeParams()
{
	return ConstructThreeParams().Equals(FLinearColor(0.2, 0.4, 0.6, 1.0));
}

bool Observe_ConstructNamedColors()
{
	return ConstructWhite().Equals(FLinearColor::White)
		&& ConstructBlack().Equals(FLinearColor::Black)
		&& ConstructRed().Equals(FLinearColor::Red)
		&& ConstructGreen().Equals(FLinearColor::Green)
		&& ConstructBlue().Equals(FLinearColor::Blue)
		&& ConstructYellow().Equals(FLinearColor::Yellow);
}

bool Observe_ConstructFourParams_CopyIndependence()
{
	FLinearColor Original = ConstructFourParams();
	FLinearColor Copy = Original;
	Copy.R = 0.0;
	return Original.Equals(FLinearColor(0.5, 0.6, 0.7, 0.8)) && Copy.R == 0.0;
}
