/**
 * @version v1
 * @summary UPROPERTY bind, Execute, Clear, then ExecuteIfBound. After BeginPlay, bInitialBound is false, bBoundAfterBind is true, LastWeight is 2.5, LastLabel is "member", bBoundAfterClear is false, and CallCount is 1.
 * @topic Feature
 */
/**
 * @version root
 * @summary UPROPERTY bind, Execute, Clear, then ExecuteIfBound. After BeginPlay, bInitialBound is false, bBoundAfterBind is true, LastWeight is 2.5, LastLabel is "member", bBoundAfterClear is false, and CallCount is 1.
 * @topic Baseline
 */
/**
 * A unicast that reports a weight and a label.
 *
 * @Covers Delegates.Clear
 * @Inputs Weight and Label
 * @Return nothing when executed
 */
delegate void FCoverageDelegateAction(float Weight, const FString&in Label);

UCLASS()
class ACoverageDelegateMemberRuntimeActor : AActor
{
	UPROPERTY()
	FCoverageDelegateAction OnAction;

	UPROPERTY()
	bool bInitialBound = true;

	UPROPERTY()
	bool bBoundAfterBind = false;

	UPROPERTY()
	bool bBoundAfterClear = true;

	UPROPERTY()
	float LastWeight = 0.0f;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	int CallCount = 0;

	/**
	 * Walks IsBound, BindUFunction, Execute, Clear, and ExecuteIfBound.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; CallCount ends at 1 and LastLabel is "member"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bInitialBound = OnAction.IsBound();

		OnAction.BindUFunction(this, n"HandleAction");
		bBoundAfterBind = OnAction.IsBound();
		OnAction.Execute(2.5f, "member");

		OnAction.Clear();
		bBoundAfterClear = OnAction.IsBound();
		OnAction.ExecuteIfBound(9.0f, "cleared");
	}

	/**
	 * Records Weight, Label, and increments CallCount.
	 *
	 * @Covers Delegates.Execute
	 * @Param Weight the payload
	 * @Param Label the payload label
	 * @Inputs Weight and Label
	 * @Return nothing; CallCount gains 1
	 */
	UFUNCTION()
	void HandleAction(float Weight, const FString&in Label)
	{
		LastWeight = Weight;
		LastLabel = Label;
		CallCount += 1;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Inputs a local ACoverageDelegateMemberRuntimeActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateMemberRuntimeActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay CallCount.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Inputs this
	 * @Return 0
	 * @Boundary default CallCount
	 */
	UFUNCTION()
	int CallCountDefault()
	{
		return CallCount;
	}

	/**
	 * Observe that bInitialBound starts true before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Inputs this
	 * @Return true when bInitialBound is true
	 * @Boundary declared default
	 */
	UFUNCTION()
	bool InitialBoundDefaultTrue()
	{
		return bInitialBound;
	}
}
/** @end */
