// Theme: Definitions.UFunction. WorldStory: BlueprintOverride ReceiveBeginPlay.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 5 AssertCompiles.
// sha256=733f71da2f15523ed8850dd846a0f6c73d94cfe156e4f67b720ec1c826d8a03a; lines 96-102.
// C++ currently wraps this AssertCompiles in #if 0 (#as-engine-behavior BlueprintOverride).
// Oracle: AUFuncBPOverrideActor is an AActor subclass with ReceiveBeginPlay override.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncBPOverrideActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void ReceiveBeginPlay()
	{
	}
}

int Observe_ReceiveBeginPlay_IsAActorWhenSet()
{
	AUFuncBPOverrideActor Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_ReceiveBeginPlay_EmptyDefaultIsNull()
{
	AUFuncBPOverrideActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_ReceiveBeginPlay_AssignAliases()
{
	AUFuncBPOverrideActor First;
	AUFuncBPOverrideActor Second;
	First = Second;
	return First is Second;
}
