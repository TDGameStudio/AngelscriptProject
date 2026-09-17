/**
 * @version v1
 * @summary Enum parameter and return through SetState and GetNextState, plus an if-chain that walks Idle → Running → Paused → Stopped → Idle. C++ reads CurrentState and FunctionCallCount by path after BeginPlay, so those names are.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Enum parameter and return through SetState and GetNextState, plus an if-chain that walks Idle → Running → Paused → Stopped → Idle. C++ reads CurrentState and FunctionCallCount by path after BeginPlay, so those names are.
 * @topic Baseline
 */
UENUM()
enum EUsageEnum
{
	StateIdle,
	StateRunning,
	StatePaused,
	StateStopped
}

UCLASS()
class ACoverageUEnumUsageActor : AActor
{
	UPROPERTY()
	EUsageEnum CurrentState = EUsageEnum::StateIdle;

	UPROPERTY()
	int FunctionCallCount = 0;

	/**
	 * WorldStory: assign a local Running state, SetState to Paused, then
	 * GetNextState to Stopped, and write FunctionCallCount 42.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumUsage
	 * @Inputs none
	 * @Return CurrentState StatePaused and FunctionCallCount 42
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EUsageEnum LocalState = EUsageEnum::StateRunning;
		check(LocalState == EUsageEnum::StateRunning);

		SetState(EUsageEnum::StatePaused);
		check(CurrentState == EUsageEnum::StatePaused);

		EUsageEnum ReturnedState = GetNextState(CurrentState);
		check(ReturnedState == EUsageEnum::StateStopped);

		FunctionCallCount = 42;
	}

	/**
	 * Store a new enumerator on CurrentState.
	 *
	 * @Kind Action
	 * @Covers UEnum.UEnumUsage
	 * @Inputs the enumerator to store
	 * @Return nothing; CurrentState becomes NewState
	 * @Param NewState the enumerator to store
	 */
	void SetState(EUsageEnum NewState)
	{
		CurrentState = NewState;
	}

	/**
	 * Return the next usage state in Idle → Running → Paused → Stopped → Idle.
	 *
	 * @Covers UEnum.UEnumUsage
	 * @Inputs the current enumerator
	 * @Return the next enumerator, wrapping Stopped to Idle
	 * @Param Current the state to advance
	 */
	EUsageEnum GetNextState(EUsageEnum Current)
	{
		if (Current == EUsageEnum::StateIdle)
			return EUsageEnum::StateRunning;
		else if (Current == EUsageEnum::StateRunning)
			return EUsageEnum::StatePaused;
		else if (Current == EUsageEnum::StatePaused)
			return EUsageEnum::StateStopped;
		else
			return EUsageEnum::StateIdle;
	}

	/**
	 * Observe the BeginPlay oracle: Paused at 2 and FunctionCallCount 42.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumUsage
	 * @Inputs this actor after BeginPlay
	 * @Return true when CurrentState is Paused (2) and FunctionCallCount is 42
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (CurrentState != EUsageEnum::StatePaused)
		{
			return false;
		}
		if (int(CurrentState) != 2)
		{
			return false;
		}
		return FunctionCallCount == 42;
	}

	/**
	 * Observe that StateIdle is the empty zero enumerator.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumUsage
	 * @Inputs StateIdle
	 * @Return 0
	 * @Boundary empty Idle
	 */
	UFUNCTION()
	int IdleEmpty()
	{
		return int(EUsageEnum::StateIdle);
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumUsage
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumUsageActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that GetNextState wraps Stopped to Idle and advances Idle to Running.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumUsage
	 * @Inputs StateStopped and StateIdle
	 * @Return true when Stopped wraps to Idle and Idle advances to Running
	 * @Boundary wrap Stopped to Idle
	 */
	UFUNCTION()
	bool WrapBoundary()
	{
		if (GetNextState(EUsageEnum::StateStopped) != EUsageEnum::StateIdle)
		{
			return false;
		}
		return GetNextState(EUsageEnum::StateIdle) == EUsageEnum::StateRunning;
	}
}
/** @end */
