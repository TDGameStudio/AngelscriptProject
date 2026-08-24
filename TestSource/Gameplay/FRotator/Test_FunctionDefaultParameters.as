// Theme: Gameplay.FRotator. Positive default-parameter oracles.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionDefaultParameters
// Oracle: AddWithDefault((10,20,30),(5,10,15))==(15,30,45);
// AddWithImplicitDefault((10,20,30))==(10,20,30).
// Extra: AddWithDefault of Zero. DefaultSafe.

FRotator AddWithDefault(FRotator a, FRotator b = FRotator::ZeroRotator)
{
	return a + b;
}

FRotator AddWithImplicitDefault(FRotator a)
{
	return AddWithDefault(a);
}

bool Observe_AddWithDefault_Explicit()
{
	return AddWithDefault(FRotator(10, 20, 30), FRotator(5, 10, 15)) == FRotator(15, 30, 45);
}

bool Observe_AddWithImplicitDefault()
{
	return AddWithImplicitDefault(FRotator(10, 20, 30)) == FRotator(10, 20, 30);
}

bool Observe_AddWithDefault_DefaultEmpty()
{
	return AddWithDefault(FRotator()) == FRotator::ZeroRotator;
}

bool Observe_AddWithImplicitDefault_CopyIndependence()
{
	FRotator Input = FRotator(10, 20, 30);
	FRotator Result = AddWithImplicitDefault(Input);
	Result.Pitch = 0.0;
	return Input == FRotator(10, 20, 30);
}
