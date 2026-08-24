// Theme: World.Blueprint. WorldStory: CDO and instance keep parent default values.
// C++: AngelscriptBlueprintChildTests.cpp::DefaultPreservation
// Oracle: DefaultCounter 23, bDefaultToggle true, DefaultLabel "ScriptParentDefault" on CDO
// and instance.
// Extra: empty sibling Counter 0, toggle false, Label empty. Do not spawn from script. FixtureIsolated.

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
