/**
 * @version v1
 * @summary HotReload VersionPair Before. Full reload drops RemovedValue.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Full reload drops RemovedValue.
 * @topic Baseline
 */
// Retained on old class after reload: RemovedValue layout (Value=3, RemovedValue=4).
// Replaced in After: UClass identity; RemovedValue dropped; Value default 3 -> 5.
// Oracle Before: RemovedValue present.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadRemovalTarget : UObject
{
	UPROPERTY()
	int Value;

	UPROPERTY()
	int RemovedValue;

	default Value = 3;
	default RemovedValue = 4;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Full reload drops RemovedValue.
 * @topic HotReload
 */
// Oracle After: replacement class has no RemovedValue; old class still has it.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadRemovalTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 5;
}
/** @end */
