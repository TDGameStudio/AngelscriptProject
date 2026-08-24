// Theme: Definitions.UProperty. WorldStory: Category = "Stats" UPROPERTY compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_Category.
// CSV TrailingOracle leaked Specifiers_Negative AddExpectedErrorPlain; C++ is AssertCompiles.
// Extra: empty sibling Health 0 is independent. FixtureIsolated.

class AUPropCatActor : AActor
{
	UPROPERTY(Category = "Stats")
	int Health = 100;
}

class AUPropCatActorEmpty : AActor
{
	UPROPERTY(Category = "Stats")
	int Health = 0;
}

int Observe_UPropCat_DefaultHealth()
{
	return 100;
}

int Observe_UPropCat_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
