/**
 * @version v1
 * @summary HotReload VersionPair Before. Survivor plus UReloadRemovedTarget.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Survivor plus UReloadRemovedTarget.
 * @topic Baseline
 */
UCLASS()
class UReloadSurvivorTarget : UObject
{
}

UCLASS()
class UReloadRemovedTarget : UObject
{
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Only the survivor class remains.
 * @topic HotReload
 */
UCLASS()
class UReloadSurvivorTarget : UObject
{
}
/** @end */
