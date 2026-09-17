/**
 * @version v1
 * @summary HotReload VersionPair Before. Full reload replaces Value type.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Full reload replaces Value type.
 * @topic Baseline
 */
// Retained on old class: int Value default 8.
// Replaced in After: Value type int -> FString; default "Reloaded".
// Oracle Before: Value is FIntProperty.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadTypeChangeTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 8;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Full reload replaces Value type.
 * @topic HotReload
 */
// Oracle After: FullReload handled; replacement class Value is not FIntProperty.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadTypeChangeTarget : UObject
{
	UPROPERTY()
	FString Value;

	default Value = "Reloaded";
}
/** @end */
