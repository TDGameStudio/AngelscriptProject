/**
 * An enum class : uint16 with explicit values and GetNextState. C++ reads
 * CurrentState, ScopedValue, and ReturnedValue by path after BeginPlay, so those
 * names are kept.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumClassUsage
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumClassUsage
 * @Provenance Theme: Definitions.UEnum. WorldStory enum class : uint16 with explicit values and GetNextState.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumClassUsage
 * @Provenance Oracle after BeginPlay: CurrentState Armed=7, ScopedValue=7, ReturnedValue=12 (Fired).
 * @Provenance Extra: Idle is the empty 0 enumerator; nullptr actor is the empty handle; GetNextState(Armed) returns Fired.
 * @Provenance FixtureIsolated. Keep CurrentState / ScopedValue / ReturnedValue names.
 */

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

	/**
	 * WorldStory: GetNextState from Idle to Armed, store 7, and keep Fired as 12.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumClassUsage
	 * @Inputs none
	 * @Return CurrentState Armed, ScopedValue 7, ReturnedValue 12
	 */
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

	/**
	 * Return Armed from Idle, otherwise Fired.
	 *
	 * @Covers UEnum.UEnumClassUsage
	 * @Inputs the current enumerator
	 * @Return Armed when Idle, otherwise Fired
	 * @Param State the state to advance
	 */
	EClassScopedState GetNextState(EClassScopedState State)
	{
		if (State == EClassScopedState::Idle)
			return EClassScopedState::Armed;

		return EClassScopedState::Fired;
	}

	/**
	 * Observe the BeginPlay oracle: Armed at 7 and Fired stored as 12.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumClassUsage
	 * @Inputs this actor after BeginPlay
	 * @Return true when CurrentState is Armed, ScopedValue is 7, and ReturnedValue is 12
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (CurrentState != EClassScopedState::Armed)
		{
			return false;
		}
		if (ScopedValue != 7)
		{
			return false;
		}
		return ReturnedValue == 12;
	}

	/**
	 * Observe that Idle is the empty zero enumerator.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumClassUsage
	 * @Inputs Idle
	 * @Return 0
	 * @Boundary empty Idle
	 */
	UFUNCTION()
	int IdleEmpty()
	{
		return int(EClassScopedState::Idle);
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumClassUsage
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumClassUsageActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that GetNextState from Armed or Fired returns Fired.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumClassUsage
	 * @Inputs Armed and Fired
	 * @Return true when both non-Idle inputs return Fired
	 * @Boundary non-Idle
	 */
	UFUNCTION()
	bool NonIdleBoundary()
	{
		if (GetNextState(EClassScopedState::Armed) != EClassScopedState::Fired)
		{
			return false;
		}
		return GetNextState(EClassScopedState::Fired) == EClassScopedState::Fired;
	}
}
