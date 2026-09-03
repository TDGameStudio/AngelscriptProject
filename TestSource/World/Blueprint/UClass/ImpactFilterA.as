/**
 * Blueprint A, whose parent is this script and which must be marked impacted by a
 * change to it. C++ compiles this as the module TestBPImpactFilterA; its companion
 * ImpactFilterB carries the non-impacted parent.
 *
 * @Theme World.Blueprint
 * @Subject Blueprint.ImpactFilterA
 * @Harness UClass
 * @Tag World.Blueprint.ImpactFilterA
 * @Provenance Theme: World.Blueprint. WorldStory: Blueprint A is impacted by this script change; B is not.
 * @Provenance C++: AngelscriptBlueprintImpactTests.cpp::ChangedScriptFilter block 1
 * @Provenance Oracle: bAImpacted true, bBImpacted false.
 * @Provenance Extra: Value 1; empty sibling Value 0. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestBPImpactFilterA : AActor
{
	UPROPERTY()
	int Value = 1;
}

/**
 * The sibling holding the zeroed value, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ImpactFilterA
 * @Inputs none
 * @Return an actor identical in shape but with Value 0
 * @Boundary zeroed value
 */
UCLASS()
class ATestBPImpactFilterAEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
