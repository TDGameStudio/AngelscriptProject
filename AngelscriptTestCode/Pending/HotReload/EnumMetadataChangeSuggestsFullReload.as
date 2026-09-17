/**
 * @version v1
 * @summary HotReload VersionPair Before. Alpha UMETA DisplayName Alpha.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Alpha UMETA DisplayName Alpha.
 * @topic Baseline
 */
UENUM(BlueprintType)
enum class EHotReloadChangeClassificationEnumMetadataState : uint8
{
	Alpha UMETA(DisplayName="Alpha"),
	Beta
}

UCLASS()
class UHotReloadChangeClassificationEnumMetadataTarget : UObject
{
	UPROPERTY()
	EHotReloadChangeClassificationEnumMetadataState State;

	default State = EHotReloadChangeClassificationEnumMetadataState::Alpha;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Alpha UMETA DisplayName Alpha Reloaded.
 * @topic HotReload
 */
UENUM(BlueprintType)
enum class EHotReloadChangeClassificationEnumMetadataState : uint8
{
	Alpha UMETA(DisplayName="Alpha Reloaded"),
	Beta
}

UCLASS()
class UHotReloadChangeClassificationEnumMetadataTarget : UObject
{
	UPROPERTY()
	EHotReloadChangeClassificationEnumMetadataState State;

	default State = EHotReloadChangeClassificationEnumMetadataState::Alpha;
}
/** @end */
