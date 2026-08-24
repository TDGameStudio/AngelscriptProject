// Theme: Definitions.UProperty. WorldStory: basic UPROPERTY compiles and keeps Health 100.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_Basic.
// Extra: empty sibling Health 0 is independent. FixtureIsolated.

class AUPropBasicActor : AActor
{
	UPROPERTY()
	int Health = 100;
}

class AUPropBasicActorEmpty : AActor
{
	UPROPERTY()
	int Health = 0;
}

int Observe_UPropBasic_DefaultHealth()
{
	return 100;
}

int Observe_UPropBasic_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
