// Theme: Gameplay.FRotator. Positive return-value oracles.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionReturnValues
// Oracle: ReturnZeroRotator Zero; ReturnCustomRotator (45,90,135);
// ReturnComputedRotator (15,30,45).
// Extra: default empty is Zero; copy independence of computed sum. DefaultSafe.

FRotator ReturnZeroRotator()
{
	return FRotator::ZeroRotator;
}

FRotator ReturnCustomRotator()
{
	return FRotator(45, 90, 135);
}

FRotator ReturnComputedRotator()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(5, 10, 15);
	return a + b;
}

bool Observe_ReturnZeroRotator()
{
	return ReturnZeroRotator() == FRotator::ZeroRotator;
}

bool Observe_ReturnCustomRotator()
{
	return ReturnCustomRotator() == FRotator(45, 90, 135);
}

bool Observe_ReturnComputedRotator()
{
	return ReturnComputedRotator() == FRotator(15, 30, 45);
}

bool Observe_ReturnZeroRotator_DefaultEmpty()
{
	return FRotator() == FRotator::ZeroRotator;
}

bool Observe_ReturnComputedRotator_CopyIndependence()
{
	FRotator Result = ReturnComputedRotator();
	Result.Pitch = 0.0;
	return ReturnComputedRotator() == FRotator(15, 30, 45);
}
