/**
 * A Blueprint child inherits a script BeginPlay that increments BeginPlayCount.
 * C++ verifies the count is 1 after the BP child has begun play.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.InheritsBeginPlay
 * @Harness UClass
 * @Tag Feature.Inheritance.InheritsBeginPlay
 * @Provenance Theme: Feature.Inheritance. WorldStory Blueprint child inherits script BeginPlay.
 * @Provenance C++: AngelscriptBlueprintChildTests.cpp::InheritsBeginPlay
 * @Provenance Oracle after BP child BeginPlay: BeginPlayCount==1.
 * @Provenance Extra: empty handle null; pre-BeginPlay 0. FixtureIsolated. Keep BeginPlayCount.
 */

UCLASS()
class ATestBPChildInheritsBeginPlayParent : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch so a Blueprint child inherits it.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.InheritsBeginPlay
	 * @Inputs none
	 * @Return BeginPlayCount == 1 after the world has begun play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/**
	 * Observe that a locally constructed parent has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritsBeginPlay
	 * @Inputs an actor that has not begun play
	 * @Return BeginPlayCount, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int BeforeBeginPlay()
	{
		return BeginPlayCount;
	}

	/**
	 * Observe BeginPlayCount after the world has begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritsBeginPlay
	 * @Inputs an actor whose BeginPlay the world has dispatched
	 * @Return BeginPlayCount, expected to be 1
	 */
	UFUNCTION()
	int AfterBeginPlay()
	{
		return BeginPlayCount;
	}
}
