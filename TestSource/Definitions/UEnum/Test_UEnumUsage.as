// Theme: Definitions.UEnum. WorldStory enum parameter/return plus if-chain GetNextState.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumUsage
// Oracle after BeginPlay: CurrentState StatePaused==2; FunctionCallCount==42.
// Extra: StateIdle is the empty default; nullptr actor is the empty handle; GetNextState(StateStopped) wraps to Idle.
// FixtureIsolated. Keep CurrentState / FunctionCallCount names.

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

	void SetState(EUsageEnum NewState)
	{
		CurrentState = NewState;
	}

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
}

bool Observe_Usage_BeginPlayOracle(ACoverageUEnumUsageActor Actor)
{
	Actor.BeginPlay();
	return Actor.CurrentState == EUsageEnum::StatePaused
		&& int(Actor.CurrentState) == 2
		&& Actor.FunctionCallCount == 42;
}

int Observe_Usage_IdleEmpty()
{
	return int(EUsageEnum::StateIdle);
}

bool Observe_Usage_NullDefault()
{
	ACoverageUEnumUsageActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Usage_WrapBoundary(ACoverageUEnumUsageActor Actor)
{
	return Actor.GetNextState(EUsageEnum::StateStopped) == EUsageEnum::StateIdle
		&& Actor.GetNextState(EUsageEnum::StateIdle) == EUsageEnum::StateRunning;
}
