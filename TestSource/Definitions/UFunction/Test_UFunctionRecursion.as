// Theme: Definitions.UFunction. WorldStory const recursive Factorial UFUNCTION.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UFunctionRecursion
// Oracle: Factorial(5) == 120.
// Extra: Factorial(0) and Factorial(1) empty base; nullptr actor is the empty handle; Factorial(2)==2.
// FixtureIsolated.

UCLASS()
class ACoverageMetaUFunctionRecursionActor : AActor
{
	UFUNCTION(BlueprintCallable)
	int Factorial(int Value) const
	{
		if (Value <= 1)
		{
			return 1;
		}

		return Value * Factorial(Value - 1);
	}
}

bool Observe_Factorial_Nominal(ACoverageMetaUFunctionRecursionActor Actor)
{
	return Actor.Factorial(5) == 120;
}

bool Observe_Factorial_EmptyBase(ACoverageMetaUFunctionRecursionActor Actor)
{
	return Actor.Factorial(0) == 1 && Actor.Factorial(1) == 1;
}

bool Observe_Factorial_NullDefault()
{
	ACoverageMetaUFunctionRecursionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Factorial_FirstRecursiveBoundary(ACoverageMetaUFunctionRecursionActor Actor)
{
	return Actor.Factorial(2) == 2 && Actor.Factorial(3) == 6;
}
