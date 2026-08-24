// Theme: World.Blueprint. WorldStory: Blueprint impact script parent class marker.
// C++: AngelscriptBlueprintImpactTests.cpp::ScriptParentMatch
// Oracle: C++ matches this script parent to the Blueprint asset.
// Extra: Marker default 1; empty sibling Marker 0. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestBPImpactScriptParentMatch : AActor
{
	UPROPERTY()
	int Marker = 1;
}

UCLASS()
class ATestBPImpactScriptParentMatchEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
