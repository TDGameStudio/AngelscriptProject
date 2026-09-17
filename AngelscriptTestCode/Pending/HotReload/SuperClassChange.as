/**
 * @version v1
 * @summary HotReload VersionPair Before. UReloadSuperTarget : UObject.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. UReloadSuperTarget : UObject.
 * @topic Baseline
 */
UCLASS()
class UReloadSuperTarget : UObject
{
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Super class becomes AActor.
 * @topic HotReload
 */
UCLASS()
class UReloadSuperTarget : AActor
{
}
/** @end */
