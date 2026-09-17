/**
 * @version v1
 * @summary HotReload VersionPair Before. BlueprintType enum Alpha, Beta.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. BlueprintType enum Alpha, Beta.
 * @topic Baseline
 */
UENUM(BlueprintType)
enum class EHotReloadBlueprintImpactState : uint8
{
	Alpha,
	Beta
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Adds Gamma enumerator.
 * @topic HotReload
 */
UENUM(BlueprintType)
enum class EHotReloadBlueprintImpactState : uint8
{
	Alpha,
	Beta,
	Gamma
}
/** @end */
