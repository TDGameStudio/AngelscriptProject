// Theme: Definitions.UProperty. WorldStory: EditAnywhere UPROPERTY compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_EditAnywhere.
// Extra: empty sibling Health 0 is independent. FixtureIsolated.

class AUPropEditActor : AActor
{
	UPROPERTY(EditAnywhere)
	int Health = 100;
}

class AUPropEditActorEmpty : AActor
{
	UPROPERTY(EditAnywhere)
	int Health = 0;
}

int Observe_UPropEdit_DefaultHealth()
{
	return 100;
}

int Observe_UPropEdit_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
