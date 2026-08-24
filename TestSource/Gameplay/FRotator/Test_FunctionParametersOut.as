// Theme: Gameplay.FRotator. Positive &out parameter oracles.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionParametersOut
// Oracle: WriteRotator (45,90,180); WriteMultipleRotators A Zero, B (10,20,30).
// Extra: default out before write is Zero. DefaultSafe.

void WriteRotator(FRotator&out r)
{
	r = FRotator(45, 90, 180);
}

void WriteMultipleRotators(FRotator&out a, FRotator&out b)
{
	a = FRotator::ZeroRotator;
	b = FRotator(10, 20, 30);
}

bool Observe_WriteRotator_Nominal()
{
	FRotator OutValue;
	WriteRotator(OutValue);
	return OutValue == FRotator(45, 90, 180);
}

bool Observe_WriteMultipleRotators_Nominal()
{
	FRotator OutA;
	FRotator OutB;
	WriteMultipleRotators(OutA, OutB);
	return OutA == FRotator::ZeroRotator && OutB == FRotator(10, 20, 30);
}

bool Observe_WriteRotator_DefaultEmptyBeforeWrite()
{
	FRotator OutValue;
	return OutValue == FRotator::ZeroRotator;
}

bool Observe_WriteMultipleRotators_CopyIndependence()
{
	FRotator OutA;
	FRotator OutB;
	WriteMultipleRotators(OutA, OutB);
	OutA.Pitch = 99.0;
	return OutB == FRotator(10, 20, 30);
}
