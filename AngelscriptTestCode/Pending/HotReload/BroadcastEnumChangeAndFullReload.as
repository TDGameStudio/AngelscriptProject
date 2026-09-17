/**
 * @version v1
 * @summary HotReload VersionPair Before. Enum Alpha/Beta=4, default Alpha.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Enum Alpha/Beta=4, default Alpha.
 * @topic Baseline
 */
// Retained after reload: EHotReloadEventState, UHotReloadEventCarrier, State property, Alpha/Beta=4.
// Replaced in After: Gamma=9 added; default State = Gamma.
// Oracle: FullReload + OnEnumChanged once; old names count 2. FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadEventState : uint16
{
	Alpha,
	Beta = 4
}

UCLASS()
class UHotReloadEventCarrier : UObject
{
	UPROPERTY()
	EHotReloadEventState State;

	default State = EHotReloadEventState::Alpha;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Enum gains Gamma=9, default Gamma.
 * @topic HotReload
 */
UENUM(BlueprintType)
enum class EHotReloadEventState : uint16
{
	Alpha,
	Beta = 4,
	Gamma = 9
}

UCLASS()
class UHotReloadEventCarrier : UObject
{
	UPROPERTY()
	EHotReloadEventState State;

	default State = EHotReloadEventState::Gamma;
}
/** @end */
