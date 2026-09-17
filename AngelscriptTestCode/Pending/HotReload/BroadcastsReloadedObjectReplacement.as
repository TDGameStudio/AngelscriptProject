/**
 * @version v1
 * @summary HotReload VersionPair Before. Literal asset full-reload V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Literal asset full-reload V1.
 * @topic Baseline
 */
// Retained across full reload broadcast: canonical asset name ReloadExampleAsset and package identity of the replacement pair.
// Replaced in After: ULiteralReloadAsset gains ExtraValue=2; generated class object is new (CLASS_NewerVersionExists on the old class).
// FixtureIsolated. V1 must not expose ExtraValue.

UCLASS()
class ULiteralReloadAsset : UObject
{
}

asset ReloadExampleAsset of ULiteralReloadAsset
{
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Literal asset full-reload V2.
 * @topic HotReload
 */
UCLASS()
class ULiteralReloadAsset : UObject
{
	UPROPERTY()
	int ExtraValue = 2;
}

asset ReloadExampleAsset of ULiteralReloadAsset
{
}
/** @end */
