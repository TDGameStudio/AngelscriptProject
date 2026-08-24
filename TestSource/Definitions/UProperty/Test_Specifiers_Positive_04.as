// Theme: Definitions.UProperty. WorldStory: BlueprintReadOnly UPROPERTY compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_BPReadOnly.
// Extra: empty sibling Health 0 is independent. FixtureIsolated.

class AUPropBPROActor : AActor
{
	UPROPERTY(BlueprintReadOnly)
	int Health = 100;
}

class AUPropBPROActorEmpty : AActor
{
	UPROPERTY(BlueprintReadOnly)
	int Health = 0;
}

int Observe_UPropBPRO_DefaultHealth()
{
	return 100;
}

int Observe_UPropBPRO_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
