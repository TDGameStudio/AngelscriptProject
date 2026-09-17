/**
 * @version v1
 * @summary HotReload VersionPair Before. Warmup carrier so initial compile is finished.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Warmup carrier so initial compile is finished.
 * @topic Baseline
 */
UCLASS()
class UEnumCreatedWarmupCarrier : UObject
{
	UPROPERTY()
	int Revision = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. First compile of EHotReloadCreatedState (not a warmup reload).
 * @topic HotReload
 */
UENUM(BlueprintType)
enum class EHotReloadCreatedState : uint8
{
	Alpha,
	Beta
}

/** Runs the created enum probe path and returns the observed result. */
int RunCreatedEnumProbe()
{
	EHotReloadCreatedState State = EHotReloadCreatedState::Beta;
	int Result = State == EHotReloadCreatedState::Beta ? 2 : 0;
	Log(n"HotReloadEnumDelegateTests", "Created V1 RunCreatedEnumProbe State=Beta Result=" + Result);
	return Result;
}
/** @end */
