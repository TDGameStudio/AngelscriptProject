/**
 * @version v1
 * @summary HotReload VersionPair Before. After-PIE structural LevelScript V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. After-PIE structural LevelScript V1.
 * @topic Baseline
 */
// Retained in the first PIE session: ExistingValue=12, GetValue returns ExistingValue.
// Replaced after PIE ends: After adds AddedValue=30 and GetValue ExistingValue+AddedValue for the next session.
// FixtureIsolated. First-session InvokeGetValue is 12.

UCLASS(Blueprintable)
class AHotReloadPIEAfterGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEAfterLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 12;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. After-PIE structural LevelScript V2.
 * @topic HotReload
 */
UCLASS(Blueprintable)
class AHotReloadPIEAfterGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEAfterLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 12;

	UPROPERTY()
	int AddedValue = 30;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + AddedValue;
	}
}
/** @end */
