// Theme: Definitions.UFunction. WorldStory: Server specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 8 AssertCompiles.
// sha256=b39eecc8662abbcc9fe6ee3640fc0991aecd23654a15a6db24ffae72c7cfd7ac; lines 130-136.
// Oracle: AUFuncServerActor.ServerDoAction() is a valid Server UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncServerActor : AActor
{
	UFUNCTION(Server)
	void ServerDoAction()
	{
	}
}

int Observe_ServerDoAction_CallCompletes(AUFuncServerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_08 setup: required Actor is null");
	}
	Actor.ServerDoAction();
	return 0;
}

int Observe_ServerDoAction_EmptyDefaultIsNull()
{
	AUFuncServerActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_ServerDoAction_AssignAliases()
{
	AUFuncServerActor First;
	AUFuncServerActor Second;
	First = Second;
	return First is Second;
}
