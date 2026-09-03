/**
 * Blueprint B, the non-impacted parent: changing the other filter must not mark this
 * one impacted. C++ compiles this as the module TestBPImpactFilterB; its companion
 * ImpactFilterA carries the impacted parent.
 *
 * @Theme World.Blueprint
 * @Subject Blueprint.ImpactFilterB
 * @Harness UClass
 * @Tag World.Blueprint.ImpactFilterB
 * @Provenance Theme: World.Blueprint. WorldStory: Blueprint B parent is this script; A is the other filter.
 * @Provenance C++: AngelscriptBlueprintImpactTests.cpp::ChangedScriptFilter block 2
 * @Provenance Oracle: changing A does not mark B impacted (this class is the non-impacted parent).
 * @Provenance Extra: Value 2; empty sibling Value 0. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestBPImpactFilterB : AActor
{
	UPROPERTY()
	int Value = 2;
}

/**
 * The sibling holding the zeroed value, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ImpactFilterB
 * @Inputs none
 * @Return an actor identical in shape but with Value 0
 * @Boundary zeroed value
 */
UCLASS()
class ATestBPImpactFilterBEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
