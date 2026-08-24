// Theme: Gameplay.FRotator. Positive value-parameter oracles.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionParametersValue
// Oracle: AcceptRotator(10,20,30) == (20,40,60); AcceptTwoRotators (10,20,30)+(5,10,15)==(15,30,45).
// Extra: AcceptRotator default Zero; copy independence. DefaultSafe.

FRotator AcceptRotator(FRotator r)
{
	return r * 2.0;
}

FRotator AcceptTwoRotators(FRotator a, FRotator b)
{
	return a + b;
}

bool Observe_AcceptRotator_Nominal()
{
	return AcceptRotator(FRotator(10, 20, 30)) == FRotator(20, 40, 60);
}

bool Observe_AcceptTwoRotators_Nominal()
{
	return AcceptTwoRotators(FRotator(10, 20, 30), FRotator(5, 10, 15)) == FRotator(15, 30, 45);
}

bool Observe_AcceptRotator_DefaultEmpty()
{
	return AcceptRotator(FRotator()) == FRotator::ZeroRotator;
}

bool Observe_AcceptTwoRotators_CopyIndependence()
{
	FRotator A = FRotator(10, 20, 30);
	FRotator B = FRotator(5, 10, 15);
	FRotator Sum = AcceptTwoRotators(A, B);
	Sum.Pitch = 0.0;
	return A == FRotator(10, 20, 30) && B == FRotator(5, 10, 15);
}
