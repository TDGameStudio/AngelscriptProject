/**
 * @version v1
 * @summary HotReload VersionPair Before. Game-instance subsystem soft-reload callable body.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Game-instance subsystem soft-reload callable body.
 * @topic Baseline
 */
// Retained after reload: UClass identity; UScriptGameInstanceSubsystem derivation; existing instance.
// Replaced in After: GetValue 13 -> 31.
// Oracle Before: ExecuteSubsystemValue == 13.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadGameInstanceSubsystemTarget : UScriptGameInstanceSubsystem
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 13;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Game-instance subsystem soft-reload callable body.
 * @topic HotReload
 */
// Oracle After: SoftReloadOnly handled; existing instance ExecuteSubsystemValue == 31.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadGameInstanceSubsystemTarget : UScriptGameInstanceSubsystem
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 31;
	}
}
/** @end */
