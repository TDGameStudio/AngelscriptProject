/**
 * @version v1
 * @summary HotReload VersionPair Before. EReloadAnalysisState Alpha=1, Beta=4.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. EReloadAnalysisState Alpha=1, Beta=4.
 * @topic Baseline
 */
UENUM(BlueprintType)
enum class EReloadAnalysisState : uint16
{
	Alpha = 1,
	Beta = 4
}

UCLASS()
class UReloadEnumValueCarrier : UObject
{
	UPROPERTY()
	EReloadAnalysisState State;

	default State = EReloadAnalysisState::Alpha;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Beta enumerator value becomes 7.
 * @topic HotReload
 */
UENUM(BlueprintType)
enum class EReloadAnalysisState : uint16
{
	Alpha = 1,
	Beta = 7
}

UCLASS()
class UReloadEnumValueCarrier : UObject
{
	UPROPERTY()
	EReloadAnalysisState State;

	default State = EReloadAnalysisState::Alpha;
}
/** @end */
