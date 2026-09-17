/**
 * @version v1
 * @summary Parent and child BeginPlay/Tick step chain. C++ verifies after BeginPlay ParentBeginPlayCount==1 and ChildBeginPlayCount==1, and after ticks both tick counts are at least OverrideChainTickCount. Tick(0.0) increments both.
 * @topic Feature
 */
/**
 * @version root
 * @summary Parent and child BeginPlay/Tick step chain. C++ verifies after BeginPlay ParentBeginPlayCount==1 and ChildBeginPlayCount==1, and after ticks both tick counts are at least OverrideChainTickCount. Tick(0.0) increments both.
 * @topic Baseline
 */
UCLASS()
class ATestBPChildOverrideChainParent : AActor
{
	UPROPERTY()
	int ParentBeginPlayCount = 0;

	UPROPERTY()
	int ParentTickCount = 0;

	/**
	 * Parent BeginPlay step used by both parent and child BeginPlay.
	 *
	 * @Kind Action
	 * @Covers Inheritance.OverrideChain
	 * @Inputs none
	 * @Return ParentBeginPlayCount incremented
	 */
	UFUNCTION()
	void ParentBeginPlayStep()
	{
		ParentBeginPlayCount += 1;
	}

	/**
	 * Parent Tick step used by both parent and child Tick.
	 *
	 * @Kind Action
	 * @Covers Inheritance.OverrideChain
	 * @Inputs none
	 * @Return ParentTickCount incremented
	 */
	UFUNCTION()
	void ParentTickStep()
	{
		ParentTickCount += 1;
	}

	/**
	 * WorldStory: parent BeginPlay runs ParentBeginPlayStep.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.OverrideChain
	 * @Inputs none
	 * @Return ParentBeginPlayCount == 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParentBeginPlayStep();
	}

	/**
	 * WorldStory: parent Tick runs ParentTickStep.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.OverrideChain
	 * @Inputs the frame delta
	 * @Return ParentTickCount incremented
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ParentTickStep();
	}
}

UCLASS()
class ATestBPChildOverrideChainScriptChild : ATestBPChildOverrideChainParent
{
	UPROPERTY()
	int ChildBeginPlayCount = 0;

	UPROPERTY()
	int ChildTickCount = 0;

	/**
	 * Child BeginPlay step run after the parent step.
	 *
	 * @Kind Action
	 * @Covers Inheritance.OverrideChain
	 * @Inputs none
	 * @Return ChildBeginPlayCount incremented
	 */
	UFUNCTION()
	void ChildBeginPlayStep()
	{
		ChildBeginPlayCount += 1;
	}

	/**
	 * Child Tick step run after the parent step.
	 *
	 * @Kind Action
	 * @Covers Inheritance.OverrideChain
	 * @Inputs none
	 * @Return ChildTickCount incremented
	 */
	UFUNCTION()
	void ChildTickStep()
	{
		ChildTickCount += 1;
	}

	/**
	 * WorldStory: child BeginPlay runs parent then child steps.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.OverrideChain
	 * @Inputs none
	 * @Return ParentBeginPlayCount 1 and ChildBeginPlayCount 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParentBeginPlayStep();
		ChildBeginPlayStep();
	}

	/**
	 * WorldStory: child Tick runs parent then child steps.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.OverrideChain
	 * @Inputs the frame delta
	 * @Return ParentTickCount and ChildTickCount incremented
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ParentTickStep();
		ChildTickStep();
	}

	/**
	 * Observe that a locally constructed child has not begun play or ticked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.OverrideChain
	 * @Inputs an actor that has not begun play
	 * @Return the sum of all four counts, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int BeforeLifecycle()
	{
		return ParentBeginPlayCount + ChildBeginPlayCount + ParentTickCount + ChildTickCount;
	}

	/**
	 * Observe that Tick(0.0) increments both parent and child tick steps.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.OverrideChain
	 * @Inputs Tick(0.0f)
	 * @Return ParentTickCount + ChildTickCount
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int ZeroDeltaTick()
	{
		Tick(0.0f);
		return ParentTickCount + ChildTickCount;
	}

	/**
	 * Observe the BeginPlay chain after the world has begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.OverrideChain
	 * @Inputs an actor whose BeginPlay has run
	 * @Return true when both BeginPlay counts are 1
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		if (ParentBeginPlayCount != 1)
		{
			return false;
		}
		return ChildBeginPlayCount == 1;
	}
}
/** @end */
