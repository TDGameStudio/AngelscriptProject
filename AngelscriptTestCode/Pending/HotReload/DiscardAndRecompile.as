/**
 * @version v1
 * @summary HotReload VersionPair Before. Discard then recompile same module name.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Discard then recompile same module name.
 * @topic Baseline
 */
// Retained until discard: UDiscardRecompileTarget / GetVersion / Version default 1.
// Replaced after discard+recompile: this class is gone; After publishes UDiscardRecompileTargetV2 with Version default 2.
// FixtureIsolated.

UCLASS()
class UDiscardRecompileTarget : UObject
{
	UPROPERTY()
	int Version;

	default Version = 1;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Same module name, new generated class.
 * @topic HotReload
 */
UCLASS()
class UDiscardRecompileTargetV2 : UObject
{
	UPROPERTY()
	int Version;

	default Version = 2;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
/** @end */
