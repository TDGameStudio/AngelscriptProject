/**
 * @version v1
 * @summary HotReload VersionPair Before. Base property addition propagates to child.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Base property addition propagates to child.
 * @topic Baseline
 */
// Oracle Before: AddedBaseValue absent on child.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadBaseTarget : UObject
{
	UPROPERTY()
	int BaseValue;

	default BaseValue = 4;
}

UCLASS()
class UFullReloadChildTarget : UFullReloadBaseTarget
{
	UPROPERTY()
	int ChildValue;

	default ChildValue = 6;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Base property addition propagates to child.
 * @topic HotReload
 */
// Oracle After: child class exposes AddedBaseValue through the reloaded base.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadBaseTarget : UObject
{
	UPROPERTY()
	int BaseValue;

	UPROPERTY()
	int AddedBaseValue;

	default BaseValue = 5;
	default AddedBaseValue = 9;
}

UCLASS()
class UFullReloadChildTarget : UFullReloadBaseTarget
{
	UPROPERTY()
	int ChildValue;

	default ChildValue = 6;
}
/** @end */
