// Theme: Gameplay.FRotator. Positive &inout scale oracle.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionParametersInOut
// Oracle: ScaleRotator((10,20,30), 2.0) == (20,40,60).
// Extra: scale 0 yields Zero; default empty * 2 is Zero. DefaultSafe.

void ScaleRotator(FRotator&inout r, float scale)
{
	r = r * scale;
}

bool Observe_ScaleRotator_Nominal()
{
	FRotator Value = FRotator(10, 20, 30);
	ScaleRotator(Value, 2.0);
	return Value == FRotator(20, 40, 60);
}

bool Observe_ScaleRotator_ZeroScale()
{
	FRotator Value = FRotator(10, 20, 30);
	ScaleRotator(Value, 0.0);
	return Value == FRotator::ZeroRotator;
}

bool Observe_ScaleRotator_DefaultEmpty()
{
	FRotator Value = FRotator();
	ScaleRotator(Value, 2.0);
	return Value == FRotator::ZeroRotator;
}
