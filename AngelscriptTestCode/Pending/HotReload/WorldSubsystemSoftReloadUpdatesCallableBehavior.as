/**
 * @version v1
 * @summary HotReload VersionPair Before. World subsystem soft-reload callable body.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. World subsystem soft-reload callable body.
 * @topic Baseline
 */
// Retained after reload: UClass identity; UScriptWorldSubsystem derivation; existing instance.
// Replaced in After: GetValue 41 -> 64.
// Oracle Before: ExecuteSubsystemValue == 41.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadWorldSubsystemTarget : UScriptWorldSubsystem
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 41;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. World subsystem soft-reload callable body.
 * @topic HotReload
 */
// Oracle After: SoftReloadOnly handled; existing instance ExecuteSubsystemValue == 64.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadWorldSubsystemTarget : UScriptWorldSubsystem
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 64;
	}
}
/** @end */
