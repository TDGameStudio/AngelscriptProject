// Theme: Definitions.UFunction. WorldStory: BlueprintCallable with parameters.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 12 AssertCompiles.
// sha256=4fe0fd0cddb535a2de97d03671b59fafb5514fd37eadb906523f59baa87101f7; lines 174-180.
// Oracle: SetHealth(int, bool) is a valid parameterized UFUNCTION.
// Extra: SetHealth(0, false) is the zero/false boundary; empty default handle is null.
// FixtureIsolated.

class AUFuncParamsActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void SetHealth(int NewHealth, bool bNotify)
	{
	}
}

int Observe_SetHealth_CallCompletes(AUFuncParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_12 setup: required Actor is null");
	}
	Actor.SetHealth(100, true);
	return 0;
}

int Observe_SetHealth_ZeroFalseBoundary(AUFuncParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_12 setup: required Actor is null");
	}
	Actor.SetHealth(0, false);
	return 0;
}

int Observe_SetHealth_EmptyDefaultIsNull()
{
	AUFuncParamsActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
