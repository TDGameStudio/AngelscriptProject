/**
 * A script parent whose defaults a Blueprint child must preserve on both the CDO
 * and any instance. C++ reads the counter, toggle and label off both classes.
 *
 * @Theme World.Blueprint
 * @Subject Blueprint.DefaultPreservation
 * @Harness UClass
 * @Tag World.Blueprint.DefaultPreservation
 * @Provenance Theme: World.Blueprint. WorldStory: CDO and instance keep parent default values.
 * @Provenance C++: AngelscriptBlueprintChildTests.cpp::DefaultPreservation
 * @Provenance Oracle: DefaultCounter 23, bDefaultToggle true, DefaultLabel "ScriptParentDefault" on CDO
 * @Provenance and instance.
 * @Provenance Extra: empty sibling Counter 0, toggle false, Label empty. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestBPChildDefaultPreservationParent : AActor
{
	UPROPERTY()
	int DefaultCounter = 23;

	UPROPERTY()
	bool bDefaultToggle = true;

	UPROPERTY()
	FString DefaultLabel = "ScriptParentDefault";
}

/**
 * The sibling holding the emptied defaults, which C++ uses as the empty boundary.
 * Its UPROPERTYs are part of the fixture and must be kept.
 *
 * @Covers Blueprint.DefaultPreservation
 * @Inputs none
 * @Return an actor identical in shape but with a zeroed counter, a clear toggle and an empty label
 * @Boundary emptied defaults
 */
UCLASS()
class ATestBPChildDefaultPreservationParentEmpty : AActor
{
	UPROPERTY()
	int DefaultCounter = 0;

	UPROPERTY()
	bool bDefaultToggle = false;

	UPROPERTY()
	FString DefaultLabel = "";
}
