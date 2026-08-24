// Theme: Language.Syntax.Keywords. WorldStory: Super::BeginPlay inside BlueprintOverride.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 2 AssertCompiles.
// sha256=7f40fdd5ab66666a8ce5dcb2e887de710e575814354b7e6dd9d32cc1c24cc67d; lines 124-133.
// C++ currently wraps this AssertCompiles in #if 0 (#as-engine-behavior Super:: + BlueprintOverride).
// Oracle: AActorSuper is an AActor subclass. Extra: default handle is null; assigning aliases.
// FixtureIsolated.

class AActorSuper : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
	}
}

int Observe_ActorSuper_IsAActorWhenSet()
{
	AActorSuper Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_ActorSuper_EmptyDefaultIsNull()
{
	AActorSuper Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_ActorSuper_AssignAliases()
{
	AActorSuper First;
	AActorSuper Second;
	First = Second;
	return First is Second;
}
