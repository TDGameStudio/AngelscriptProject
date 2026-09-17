/**
 * @version v1
 * @summary HotReload VersionPair Before. Only UExistingReloadTarget present.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Only UExistingReloadTarget present.
 * @topic Baseline
 */
UCLASS()
class UExistingReloadTarget : UObject
{
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Adds UNewReloadTarget beside the existing class.
 * @topic HotReload
 */
UCLASS()
class UExistingReloadTarget : UObject
{
}

UCLASS()
class UNewReloadTarget : UObject
{
}
/** @end */
