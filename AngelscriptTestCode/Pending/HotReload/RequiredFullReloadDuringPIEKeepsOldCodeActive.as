/**
 * @version v1
 * @summary HotReload VersionPair Before. During-PIE required-full LevelScript V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. During-PIE required-full LevelScript V1.
 * @topic Baseline
 */
// Retained while PIE is live: GetValue() with no args returning 31. Signature change in After is last-good, not applied.
// Replaced only after PIE ends / next full path: GetValue(int Extra).
// FixtureIsolated. C++ InvokeGetValue baseline is 31.

UCLASS(Blueprintable)
class AHotReloadPIEDuringRequiredGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringRequiredLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 31;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. During-PIE required-full signature change.
 * @topic HotReload
 */
// Retained live: Before GetValue() returns 31. This signature change must not become active during PIE.
// Replaced (deferred): GetValue(int Extra) returns 99 + Extra.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadPIEDuringRequiredGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringRequiredLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	/** Returns the value. */
	UFUNCTION()
	int GetValue(int Extra)
	{
		return 99 + Extra;
	}
}
/** @end */
