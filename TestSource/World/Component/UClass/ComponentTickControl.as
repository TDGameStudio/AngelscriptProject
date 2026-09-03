/**
 * Component ticking disabled once the component has ticked three times. C++
 * verifies DisableTickCount 2 by path. Nothing is recorded until BeginPlay and
 * Tick have run.
 *
 * @Theme World.Component
 * @Subject Component.TickControl
 * @Harness UClass
 * @Tag World.Component.ComponentTickControl
 * @Provenance Theme: World.Component. WorldStory: disable component tick after three ticks.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentTickControl
 * @Provenance Oracle: VerifyByPath DisableTickCount 2 after ticks reach TestComp.TickCount >= 3.
 * @Provenance Extra: DisableTickCount 0, TickCount 0, AccumulatedTime 0 until BeginPlay/Tick.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class UTickControlComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	float AccumulatedTime = 0.0f;

	/**
	 * Count every tick and accumulate the elapsed time.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickControl
	 * @Inputs the frame delta
	 * @Return TickCount incremented and AccumulatedTime grown by the delta
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount++;
		AccumulatedTime += DeltaTime;
	}
}

UCLASS()
class ACoverageComponentTickControlActor : AActor
{
	UPROPERTY(DefaultComponent)
	UTickControlComponent TestComp;

	UPROPERTY()
	int DisableTickCount = 0;

	/**
	 * WorldStory: BeginPlay records that the component still has ticking enabled.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickControl
	 * @Inputs a default-attached ticking component
	 * @Return DisableTickCount == 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (TestComp.IsComponentTickEnabled())
		{
			DisableTickCount = 1;
		}
	}

	/**
	 * WorldStory: once the component has ticked three times, disable its ticking.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickControl
	 * @Inputs the frame delta, unused
	 * @Return DisableTickCount == 2 once the component has been switched off
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TestComp.TickCount >= 3 && DisableTickCount == 1)
		{
			TestComp.SetComponentTickEnabled(false);
			DisableTickCount = 2;
		}
	}
}
