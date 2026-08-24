// Theme: World.Blueprint. WorldStory: Blueprint A is impacted by this script change; B is not.
// C++: AngelscriptBlueprintImpactTests.cpp::ChangedScriptFilter block 1
// Oracle: bAImpacted true, bBImpacted false.
// Extra: Value 1; empty sibling Value 0. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestBPImpactFilterA : AActor
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class ATestBPImpactFilterAEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
