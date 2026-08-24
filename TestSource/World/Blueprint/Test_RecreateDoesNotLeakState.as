// Theme: World.Blueprint. WorldStory: recreating a child does not leak mutated parent state.
// C++: AngelscriptBlueprintChildTests.cpp::RecreateDoesNotLeakState
// Oracle: first actor StatefulValue 48 after BumpState; second actor 11 after BeginPlay only;
// SecondBeginPlay 1.
// Extra: StatefulValue default 10, BeginPlayCount 0 until BeginPlay. Do not spawn from script.
// FixtureIsolated.

UCLASS()
class ATestBPChildRecreateNoLeakParent : AActor
{
	UPROPERTY()
	int StatefulValue = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		StatefulValue += 1;
	}

	UFUNCTION()
	void BumpState()
	{
		StatefulValue += 37;
	}
}
