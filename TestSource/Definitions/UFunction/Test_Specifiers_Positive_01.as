// Theme: Definitions.UFunction. WorldStory: basic UFUNCTION() on an actor method.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 1 AssertCompiles.
// sha256=a7be9bc20fe5596a379bf95f5299c4fc1a2ac874cbae7346a4d07851c88e2926; lines 50-56.
// Oracle: AUFuncBasicActor.DoSomething() is a valid empty UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncBasicActor : AActor
{
	UFUNCTION()
	void DoSomething()
	{
	}
}

int Observe_DoSomething_CallCompletes(AUFuncBasicActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_01 setup: required Actor is null");
	}
	Actor.DoSomething();
	return 0;
}

int Observe_DoSomething_EmptyDefaultIsNull()
{
	AUFuncBasicActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_DoSomething_AssignAliases()
{
	AUFuncBasicActor First;
	AUFuncBasicActor Second;
	First = Second;
	return First is Second;
}
