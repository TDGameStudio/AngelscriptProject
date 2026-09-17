/**
 * @version v1
 * @summary HotReload VersionPair Before. Impact struct payload Value=1 only.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Impact struct payload Value=1 only.
 * @topic Baseline
 */
USTRUCT()
struct FHotReloadBlueprintImpactPayload
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Adds Bonus=2 on the impact struct.
 * @topic HotReload
 */
USTRUCT()
struct FHotReloadBlueprintImpactPayload
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int Bonus = 2;
}
/** @end */
