/**
 * @version v1
 * @summary HotReload VersionPair Before. Class meta DisplayName Alpha.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Class meta DisplayName Alpha.
 * @topic Baseline
 */
UCLASS(meta=(DisplayName="Alpha"))
class UHotReloadChangeClassificationClassMetadataTarget : UObject
{
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Class metadata DisplayName change.
 * @topic HotReload
 */
UCLASS(meta=(DisplayName="Beta"))
class UHotReloadChangeClassificationClassMetadataTarget : UObject
{
}
/** @end */
