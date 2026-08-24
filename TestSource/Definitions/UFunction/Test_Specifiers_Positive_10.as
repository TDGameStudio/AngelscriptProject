// Theme: Definitions.UFunction. WorldStory: BlueprintCallable + Category combined.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 10 AssertCompiles.
// sha256=2a37b5a770f51ccb653cef50677a8073413d24217c7f81bf5f01e289fce9f086; lines 152-158.
// Oracle: AUFuncMultiSpecActor.MoveForward() is a valid multi-specifier UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncMultiSpecActor : AActor
{
	UFUNCTION(BlueprintCallable, Category = "Movement")
	void MoveForward()
	{
	}
}

int Observe_MoveForward_CallCompletes(AUFuncMultiSpecActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_10 setup: required Actor is null");
	}
	Actor.MoveForward();
	return 0;
}

int Observe_MoveForward_EmptyDefaultIsNull()
{
	AUFuncMultiSpecActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_MoveForward_AssignAliases()
{
	AUFuncMultiSpecActor First;
	AUFuncMultiSpecActor Second;
	First = Second;
	return First is Second;
}
