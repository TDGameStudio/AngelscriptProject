/**
 * @version v1
 * @summary HotReload VersionPair Before. Enum Alpha/Beta=4, default Alpha, probe Beta -> 4.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Enum Alpha/Beta=4, default Alpha, probe Beta -> 4.
 * @topic Baseline
 */
// Retained after reload: EHotReloadChangedState, UHotReloadEnumChangedCarrier, State, RunChangedEnumProbe.
// Replaced in After: Gamma=9; default Gamma; probe Gamma -> 9.
// Oracle: EnumCreatedCount 0 on reload, EnumChangedCount 1, old names 2. FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadChangedState : uint16
{
	Alpha,
	Beta = 4
}

UCLASS()
class UHotReloadEnumChangedCarrier : UObject
{
	UPROPERTY()
	EHotReloadChangedState State;

	default State = EHotReloadChangedState::Alpha;
}

/** Runs the changed enum probe path and returns the observed result. */
int RunChangedEnumProbe()
{
	EHotReloadChangedState State = EHotReloadChangedState::Beta;
	int Result = State == EHotReloadChangedState::Beta ? 4 : 0;
	Log(n"HotReloadEnumDelegateTests", "Changed V1 RunChangedEnumProbe State=Beta Result=" + Result);
	return Result;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Enum gains Gamma=9; probe Gamma -> 9.
 * @topic HotReload
 */
UENUM(BlueprintType)
enum class EHotReloadChangedState : uint16
{
	Alpha,
	Beta = 4,
	Gamma = 9
}

UCLASS()
class UHotReloadEnumChangedCarrier : UObject
{
	UPROPERTY()
	EHotReloadChangedState State;

	default State = EHotReloadChangedState::Gamma;
}

/** Runs the changed enum probe path and returns the observed result. */
int RunChangedEnumProbe()
{
	EHotReloadChangedState State = EHotReloadChangedState::Gamma;
	int Result = State == EHotReloadChangedState::Gamma ? 9 : 0;
	Log(n"HotReloadEnumDelegateTests", "Changed V2 RunChangedEnumProbe State=Gamma Result=" + Result);
	return Result;
}
/** @end */
