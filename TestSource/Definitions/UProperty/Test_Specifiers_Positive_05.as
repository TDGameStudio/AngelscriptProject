// Theme: Definitions.UProperty. WorldStory: Replicated UPROPERTY compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_Replicated.
// Extra: empty sibling Health 0 is independent. FixtureIsolated.

class AUPropRepActor : AActor
{
	UPROPERTY(Replicated)
	int Health = 100;
}

class AUPropRepActorEmpty : AActor
{
	UPROPERTY(Replicated)
	int Health = 0;
}

int Observe_UPropRep_DefaultHealth()
{
	return 100;
}

int Observe_UPropRep_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
