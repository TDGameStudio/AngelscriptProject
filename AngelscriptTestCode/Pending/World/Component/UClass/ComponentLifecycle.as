/**
 * @version v1
 * @summary A component walking BeginPlay, Tick and EndPlay. C++ verifies LifecycleStage 2 and TickCount 2 by path. The CSV marks this NegativeDiagnostic, but the method is a lifecycle oracle rather than a compile failure: the.
 * @topic World
 */
/**
 * @version root
 * @summary A component walking BeginPlay, Tick and EndPlay. C++ verifies LifecycleStage 2 and TickCount 2 by path. The CSV marks this NegativeDiagnostic, but the method is a lifecycle oracle rather than a compile failure: the.
 * @topic Baseline
 */
UCLASS()
class ULifecycleTestComponent : UActorComponent
{
	UPROPERTY()
	int LifecycleStage = 0;

	UPROPERTY()
	int TickCount = 0;

	/**
	 * WorldStory: BeginPlay advances the stage from 0 to 2.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Lifecycle
	 * @Inputs none
	 * @Return LifecycleStage == 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LifecycleStage = 2;
	}

	/**
	 * WorldStory: each Tick past BeginPlay increments the tick count.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Lifecycle
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick while the stage is 2
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (LifecycleStage == 2)
		{
			TickCount++;
		}
	}

	/**
	 * WorldStory: EndPlay advances the stage from 2 to 3.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Lifecycle
	 * @Inputs the end play reason supplied by the engine
	 * @Return LifecycleStage == 3
	 * @Param EndPlayReason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		if (LifecycleStage == 2)
		{
			LifecycleStage = 3;
		}
	}
}

/**
 * The actor that hosts the lifecycle component as a default component.
 *
 * @Covers Component.Lifecycle
 * @Inputs none
 * @Return an actor carrying one ULifecycleTestComponent
 */
UCLASS()
class ACoverageComponentLifecycleActor : AActor
{
	UPROPERTY(DefaultComponent)
	ULifecycleTestComponent TestComp;
}
/** @end */
