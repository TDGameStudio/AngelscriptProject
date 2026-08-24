// Theme: Definitions.UFunction. WorldStory: BlueprintPure const getter.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 3 AssertCompiles.
// sha256=898eda24ac3f7299c2b8ecbba0a0c90e7129165f43fd71a14651b6ae32fb03f6; lines 72-78.
// Oracle: GetHealth() returns 100. Extra: a second instance also returns 100;
// empty default handle is null.
// FixtureIsolated.

class AUFuncBPPureActor : AActor
{
	UFUNCTION(BlueprintPure)
	int GetHealth() const
	{
		return 100;
	}
}

int Observe_GetHealth_Nominal(AUFuncBPPureActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_03 setup: required Actor is null");
	}
	return Actor.GetHealth();
}

int Observe_GetHealth_SecondInstance(AUFuncBPPureActor Second)
{
	if (Second is null)
	{
		throw("Test_Specifiers_Positive_03 setup: required Second is null");
	}
	AUFuncBPPureActor First;
	return Second.GetHealth();
}

int Observe_GetHealth_EmptyDefaultIsNull()
{
	AUFuncBPPureActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
