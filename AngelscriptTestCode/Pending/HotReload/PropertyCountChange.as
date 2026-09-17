/**
 * @version v1
 * @summary HotReload VersionPair Before. Single UPROPERTY Value on UReloadPropertyTarget.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Single UPROPERTY Value on UReloadPropertyTarget.
 * @topic Baseline
 */
UCLASS()
class UReloadPropertyTarget : UObject
{
	UPROPERTY()
	int Value;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Adds ExtraValue beside Value.
 * @topic HotReload
 */
UCLASS()
class UReloadPropertyTarget : UObject
{
	UPROPERTY()
	int Value;

	UPROPERTY()
	int ExtraValue;
}
/** @end */
