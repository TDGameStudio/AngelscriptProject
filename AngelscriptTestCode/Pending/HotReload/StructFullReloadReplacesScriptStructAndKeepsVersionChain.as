/**
 * @version v1
 * @summary HotReload VersionPair Before. Script struct version chain.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Script struct version chain.
 * @topic Baseline
 */
// Retained on old struct after reload: Value=1 layout; Bonus absent; GetNewestVersion points at After.
// Replaced in After: UScriptStruct object; Bonus=2 field.
// Oracle Before: Value present; Bonus absent.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructPayload
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Script struct version chain.
 * @topic HotReload
 */
// Oracle After: struct reload broadcast once; old struct has no Bonus.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructPayload
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int Bonus = 2;
}
/** @end */
