/**
 * A script parent whose state must not leak from one created child to the next.
 * C++ bumps the state on a first actor, creates a second and verifies that the
 * second only carries the BeginPlay increment.
 *
 * @Theme World.Blueprint
 * @Subject Blueprint.RecreateDoesNotLeakState
 * @Harness UClass
 * @Tag World.Blueprint.RecreateDoesNotLeakState
 * @Provenance Theme: World.Blueprint. WorldStory: recreating a child does not leak mutated parent state.
 * @Provenance C++: AngelscriptBlueprintChildTests.cpp::RecreateDoesNotLeakState
 * @Provenance Oracle: first actor StatefulValue 48 after BumpState; second actor 11 after BeginPlay only;
 * @Provenance SecondBeginPlay 1.
 * @Provenance Extra: StatefulValue default 10, BeginPlayCount 0 until BeginPlay. Do not spawn from script.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ATestBPChildRecreateNoLeakParent : AActor
{
	UPROPERTY()
	int StatefulValue = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/**
	 * WorldStory: BeginPlay counts the dispatch and increments the state by one.
	 *
	 * @Kind WorldStory
	 * @Covers Blueprint.RecreateDoesNotLeakState
	 * @Inputs none
	 * @Return BeginPlayCount incremented and StatefulValue grown by 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		StatefulValue += 1;
	}

	/**
	 * Bump the state by a large amount so a leak would be visible on a later instance.
	 *
	 * @Kind Action
	 * @Covers Blueprint.RecreateDoesNotLeakState
	 * @Inputs none
	 * @Return StatefulValue grown by 37
	 */
	UFUNCTION()
	void BumpState()
	{
		StatefulValue += 37;
	}

	/**
	 * Observe that a locally constructed parent keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Blueprint.RecreateDoesNotLeakState
	 * @Inputs a parent that has not begun play
	 * @Return true when the state is 10 and the count is 0
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (StatefulValue != 10)
		{
			return false;
		}
		return BeginPlayCount == 0;
	}
}
