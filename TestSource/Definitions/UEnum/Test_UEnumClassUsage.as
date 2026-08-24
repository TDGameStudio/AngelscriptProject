// Theme: Definitions.UEnum. WorldStory enum class : uint16 with explicit values and GetNextState.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumClassUsage
// Oracle after BeginPlay: CurrentState Armed=7, ScopedValue=7, ReturnedValue=12 (Fired).
// Extra: Idle is the empty 0 enumerator; nullptr actor is the empty handle; GetNextState(Armed) returns Fired.
// FixtureIsolated. Keep CurrentState / ScopedValue / ReturnedValue names.

UENUM(BlueprintType)
enum class EClassScopedState : uint16
{
	Idle,
	Armed = 7,
	Fired = 12
}

UCLASS()
class ACoverageUEnumClassUsageActor : AActor
{
	UPROPERTY()
	EClassScopedState CurrentState = EClassScopedState::Armed;

	UPROPERTY()
	int ScopedValue = 0;

	UPROPERTY()
	int ReturnedValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EClassScopedState LocalState = EClassScopedState::Fired;
		check(LocalState == EClassScopedState::Fired);

		CurrentState = GetNextState(EClassScopedState::Idle);
		check(CurrentState == EClassScopedState::Armed);
		ScopedValue = int(CurrentState);
		ReturnedValue = int(LocalState);
	}

	EClassScopedState GetNextState(EClassScopedState State)
	{
		if (State == EClassScopedState::Idle)
			return EClassScopedState::Armed;

		return EClassScopedState::Fired;
	}
}

bool Observe_EnumClass_BeginPlayOracle(ACoverageUEnumClassUsageActor Actor)
{
	Actor.BeginPlay();
	return Actor.CurrentState == EClassScopedState::Armed
		&& Actor.ScopedValue == 7
		&& Actor.ReturnedValue == 12;
}

int Observe_EnumClass_IdleEmpty()
{
	return int(EClassScopedState::Idle);
}

bool Observe_EnumClass_NullDefault()
{
	ACoverageUEnumClassUsageActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_EnumClass_NonIdleBoundary(ACoverageUEnumClassUsageActor Actor)
{
	return Actor.GetNextState(EClassScopedState::Armed) == EClassScopedState::Fired
		&& Actor.GetNextState(EClassScopedState::Fired) == EClassScopedState::Fired;
}
