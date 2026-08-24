// Theme: Definitions.UFunction. WorldStory: BlueprintCallable specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 2 AssertCompiles.
// sha256=a1ad6279aa5aadcbca5410a6dac75ee23de68853cbe28b73bb24a73fa2f255c3; lines 61-67.
// Oracle: AUFuncBPCallActor.DoWork() is a valid BlueprintCallable UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncBPCallActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void DoWork()
	{
	}
}

int Observe_DoWork_CallCompletes(AUFuncBPCallActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_02 setup: required Actor is null");
	}
	Actor.DoWork();
	return 0;
}

int Observe_DoWork_EmptyDefaultIsNull()
{
	AUFuncBPCallActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_DoWork_AssignAliases()
{
	AUFuncBPCallActor First;
	AUFuncBPCallActor Second;
	First = Second;
	return First is Second;
}
