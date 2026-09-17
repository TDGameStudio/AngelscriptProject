/**
 * @version v1
 * @summary BlueprintOverride BeginPlay/Tick Super chain. C++ verifies after BeginPlay and two 0.025 ticks: BeginPlayCount==1, ChildBeginPlayCount==1, TickCount==2, ChildTickCount==2, LastDeltaMillis==25. Tick(0.0) is the zero-delta.
 * @topic Feature
 */
/**
 * @version root
 * @summary BlueprintOverride BeginPlay/Tick Super chain. C++ verifies after BeginPlay and two 0.025 ticks: BeginPlayCount==1, ChildBeginPlayCount==1, TickCount==2, ChildTickCount==2, LastDeltaMillis==25. Tick(0.0) is the zero-delta.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionOverrideBase : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int LastDeltaMillis = 0;

	/**
	 * WorldStory: base BeginPlay increments BeginPlayCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs none
	 * @Return BeginPlayCount incremented
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/**
	 * WorldStory: base Tick increments TickCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs the frame delta
	 * @Return TickCount incremented
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS()
class ACoverageUFunctionOverrideChild : ACoverageUFunctionOverrideBase
{
	UPROPERTY()
	int ChildBeginPlayCount = 0;

	UPROPERTY()
	int ChildTickCount = 0;

	/**
	 * WorldStory: child BeginPlay calls Super then increments ChildBeginPlayCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs Super::BeginPlay()
	 * @Return BeginPlayCount 1 and ChildBeginPlayCount 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		ChildBeginPlayCount += 1;
	}

	/**
	 * WorldStory: child Tick calls Super then records LastDeltaMillis.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs Super::Tick(DeltaSeconds)
	 * @Return TickCount and ChildTickCount incremented; LastDeltaMillis from DeltaSeconds
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		ChildTickCount += 1;
		LastDeltaMillis = int(DeltaSeconds * 1000.0f);
	}

	/**
	 * Observe that a locally constructed child has not begun play or ticked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs an actor that has not begun play
	 * @Return the sum of all lifecycle counters, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int CountersBeforeBeginPlay()
	{
		return BeginPlayCount + TickCount + ChildBeginPlayCount + ChildTickCount + LastDeltaMillis;
	}

	/**
	 * Observe Tick(0.0) writing LastDeltaMillis to 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs Tick(0.0f)
	 * @Return LastDeltaMillis, expected to be 0
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int TickZeroDeltaBoundary()
	{
		Tick(0.0f);
		return LastDeltaMillis;
	}

	/**
	 * Observe the Super chain after BeginPlay and two 0.025 ticks.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideBeginPlayTickAndSuperExecute
	 * @Inputs an actor after BeginPlay and two 0.025 ticks
	 * @Return true when counts are 1/1/2/2 and LastDeltaMillis is 25
	 */
	UFUNCTION()
	bool AfterBeginPlayAndTwoTicks()
	{
		if (BeginPlayCount != 1)
		{
			return false;
		}
		if (ChildBeginPlayCount != 1)
		{
			return false;
		}
		if (TickCount != 2)
		{
			return false;
		}
		if (ChildTickCount != 2)
		{
			return false;
		}
		return LastDeltaMillis == 25;
	}
}
/** @end */
