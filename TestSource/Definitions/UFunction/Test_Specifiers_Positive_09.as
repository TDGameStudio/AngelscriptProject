// Theme: Definitions.UFunction. WorldStory: Client specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 9 AssertCompiles.
// sha256=cb665a04f043fdd47d43547a8a18bee313d623be5ba8513f943d50ac86cff497; lines 141-147.
// Oracle: AUFuncClientActor.ClientReceiveData() is a valid Client UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncClientActor : AActor
{
	UFUNCTION(Client)
	void ClientReceiveData()
	{
	}
}

int Observe_ClientReceiveData_CallCompletes(AUFuncClientActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_09 setup: required Actor is null");
	}
	Actor.ClientReceiveData();
	return 0;
}

int Observe_ClientReceiveData_EmptyDefaultIsNull()
{
	AUFuncClientActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_ClientReceiveData_AssignAliases()
{
	AUFuncClientActor First;
	AUFuncClientActor Second;
	First = Second;
	return First is Second;
}
