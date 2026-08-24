// Theme: Definitions.UFunction. WorldStory: BlueprintCallable with int return.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 11 AssertCompiles.
// sha256=d7dcd1dde07c6cfb21219a7deb74b3b69d7a29b6fd70a20986acef12d925b241; lines 163-169.
// Oracle: GetScore() returns 42. Extra: a second instance also returns 42;
// empty default handle is null.
// FixtureIsolated.

class AUFuncReturnActor : AActor
{
	UFUNCTION(BlueprintCallable)
	int GetScore()
	{
		return 42;
	}
}

int Observe_GetScore_Nominal(AUFuncReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_11 setup: required Actor is null");
	}
	return Actor.GetScore();
}

int Observe_GetScore_SecondInstance(AUFuncReturnActor Second)
{
	if (Second is null)
	{
		throw("Test_Specifiers_Positive_11 setup: required Second is null");
	}
	AUFuncReturnActor First;
	return Second.GetScore();
}

int Observe_GetScore_EmptyDefaultIsNull()
{
	AUFuncReturnActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
