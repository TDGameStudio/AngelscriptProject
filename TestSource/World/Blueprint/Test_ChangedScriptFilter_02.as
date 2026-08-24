// Theme: World.Blueprint. WorldStory: Blueprint B parent is this script; A is the other filter.
// C++: AngelscriptBlueprintImpactTests.cpp::ChangedScriptFilter block 2
// Oracle: changing A does not mark B impacted (this class is the non-impacted parent).
// Extra: Value 2; empty sibling Value 0. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestBPImpactFilterB : AActor
{
	UPROPERTY()
	int Value = 2;
}

UCLASS()
class ATestBPImpactFilterBEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
