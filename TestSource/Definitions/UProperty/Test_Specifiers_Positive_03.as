// Theme: Definitions.UProperty. WorldStory: BlueprintReadWrite UPROPERTY compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_BPReadWrite.
// Extra: empty sibling Health 0 is independent. FixtureIsolated.

class AUPropBPRWActor : AActor
{
	UPROPERTY(BlueprintReadWrite)
	int Health = 100;
}

class AUPropBPRWActorEmpty : AActor
{
	UPROPERTY(BlueprintReadWrite)
	int Health = 0;
}

int Observe_UPropBPRW_DefaultHealth()
{
	return 100;
}

int Observe_UPropBPRW_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
