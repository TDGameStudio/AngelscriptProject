/**
 * A script parent that C++ matches to the Blueprint asset by its marker value.
 *
 * @Theme World.Blueprint
 * @Subject Blueprint.ScriptParentMatch
 * @Harness UClass
 * @Tag World.Blueprint.ScriptParentMatch
 * @Provenance Theme: World.Blueprint. WorldStory: Blueprint impact script parent class marker.
 * @Provenance C++: AngelscriptBlueprintImpactTests.cpp::ScriptParentMatch
 * @Provenance Oracle: C++ matches this script parent to the Blueprint asset.
 * @Provenance Extra: Marker default 1; empty sibling Marker 0. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestBPImpactScriptParentMatch : AActor
{
	UPROPERTY()
	int Marker = 1;
}

/**
 * The sibling holding the zeroed marker, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ScriptParentMatch
 * @Inputs none
 * @Return an actor identical in shape but with Marker 0
 * @Boundary zeroed marker
 */
UCLASS()
class ATestBPImpactScriptParentMatchEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
