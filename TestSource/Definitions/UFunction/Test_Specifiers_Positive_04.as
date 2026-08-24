// Theme: Definitions.UFunction. WorldStory: BlueprintEvent specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 4 AssertCompiles.
// sha256=169627921c217451afa3e3dc5cdef410cb63ad927233446da504cbd7dd651d2d; lines 83-89.
// Oracle: AUFuncBPEventActor.OnDamageReceived() is a valid BlueprintEvent UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncBPEventActor : AActor
{
	UFUNCTION(BlueprintEvent)
	void OnDamageReceived()
	{
	}
}

int Observe_OnDamageReceived_CallCompletes(AUFuncBPEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_04 setup: required Actor is null");
	}
	Actor.OnDamageReceived();
	return 0;
}

int Observe_OnDamageReceived_EmptyDefaultIsNull()
{
	AUFuncBPEventActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_OnDamageReceived_AssignAliases()
{
	AUFuncBPEventActor First;
	AUFuncBPEventActor Second;
	First = Second;
	return First is Second;
}
