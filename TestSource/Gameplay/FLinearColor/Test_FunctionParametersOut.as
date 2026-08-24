// Theme: Gameplay.FLinearColor. Positive &out parameter oracles.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersOut
// Oracle: WriteColor -> (0.25,0.5,0.75,1.0); WriteMultipleColors A Red, B Green.
// Extra: default out before write is (0,0,0,1). DefaultSafe.

void WriteColor(FLinearColor&out c)
{
	c = FLinearColor(0.25, 0.5, 0.75, 1.0);
}

void WriteMultipleColors(FLinearColor&out a, FLinearColor&out b)
{
	a = FLinearColor::Red;
	b = FLinearColor::Green;
}

bool Observe_WriteColor_Nominal()
{
	FLinearColor OutValue;
	WriteColor(OutValue);
	return OutValue.Equals(FLinearColor(0.25, 0.5, 0.75, 1.0), 0.001);
}

bool Observe_WriteMultipleColors_Nominal()
{
	FLinearColor OutA;
	FLinearColor OutB;
	WriteMultipleColors(OutA, OutB);
	return OutA == FLinearColor::Red && OutB == FLinearColor::Green;
}

bool Observe_WriteColor_DefaultEmptyBeforeWrite()
{
	FLinearColor OutValue;
	return OutValue.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0));
}

bool Observe_WriteMultipleColors_CopyIndependence()
{
	FLinearColor OutA;
	FLinearColor OutB;
	WriteMultipleColors(OutA, OutB);
	OutA.G = 1.0;
	return OutB == FLinearColor::Green && OutA.R == 1.0;
}
