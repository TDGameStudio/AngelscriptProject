/**
 * A BeginPlay override that writes BeginPlayObserved. C++ verifies the count is
 * 1 after the world has begun play. The observer covers the pre-BeginPlay zero.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.BeginPlayRunsInWorld
 * @Harness UClass
 * @Tag Feature.Inheritance.BeginPlayRunsInWorld
 * @Provenance Theme: Feature.Inheritance. WorldStory BeginPlay override writes a UPROPERTY.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::BeginPlayRunsInWorld
 * @Provenance Oracle after BeginPlay: BeginPlayObserved==1.
 * @Provenance Extra: empty handle null; pre-BeginPlay stays 0. FixtureIsolated. Keep BeginPlayObserved.
 */

UCLASS()
class ATestScriptActorBeginPlayRunsInWorld : AActor
{
	UPROPERTY()
	int BeginPlayObserved = 0;

	/**
	 * WorldStory: BeginPlay records that the world dispatched it.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BeginPlayRunsInWorld
	 * @Inputs none
	 * @Return BeginPlayObserved == 1 after the world has begun play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayObserved = 1;
	}

	/**
	 * Observe that a locally constructed actor has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BeginPlayRunsInWorld
	 * @Inputs an actor that has not begun play
	 * @Return true when BeginPlayObserved is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return BeginPlayObserved == 0;
	}

	/**
	 * Observe the BeginPlayObserved value after the world has begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BeginPlayRunsInWorld
	 * @Inputs an actor whose BeginPlay the world has dispatched
	 * @Return BeginPlayObserved, expected to be 1
	 */
	UFUNCTION()
	int AfterBeginPlay()
	{
		return BeginPlayObserved;
	}
}
