// Theme: Definitions.UFunction. WorldStory: NetMulticast specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 7 AssertCompiles.
// sha256=02c324644f2569f3ea55df4634afe9a553fb9d3bc172acf6bc192711a8cae6aa; lines 119-125.
// Oracle: AUFuncNetMCActor.MulticastEffect() is a valid NetMulticast UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncNetMCActor : AActor
{
	UFUNCTION(NetMulticast)
	void MulticastEffect()
	{
	}
}

int Observe_MulticastEffect_CallCompletes(AUFuncNetMCActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_07 setup: required Actor is null");
	}
	Actor.MulticastEffect();
	return 0;
}

int Observe_MulticastEffect_EmptyDefaultIsNull()
{
	AUFuncNetMCActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_MulticastEffect_AssignAliases()
{
	AUFuncNetMCActor First;
	AUFuncNetMCActor Second;
	First = Second;
	return First is Second;
}
