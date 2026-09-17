/**
 * @version v1
 * @summary HotReload VersionPair Before. default Value = 1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. default Value = 1.
 * @topic Baseline
 */
UCLASS()
class UHotReloadChangeClassificationDefaultStatementTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. default Value = 2.
 * @topic HotReload
 */
UCLASS()
class UHotReloadChangeClassificationDefaultStatementTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 2;
}
/** @end */
