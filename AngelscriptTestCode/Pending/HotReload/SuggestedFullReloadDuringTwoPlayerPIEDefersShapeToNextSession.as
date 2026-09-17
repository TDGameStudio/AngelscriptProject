/**
 * @version v1
 * @summary HotReload VersionPair Before. Two-player PIE suggested-full V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Two-player PIE suggested-full V1.
 * @topic Baseline
 */
// Retained during PIE: ExistingValue=10, live GetValue shape, LevelScript UClass. Shape add is deferred to the next session.
// Replaced in After: AddedValue=40; GetValue ExistingValue+1 -> ExistingValue+2. AddedValue must not apply mid-PIE.
// FixtureIsolated. C++ baseline GetValue is 11.

UCLASS(Blueprintable)
class AHotReloadMultiplayerPIESuggestedGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadMultiplayerPIESuggestedLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 1;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Two-player PIE suggested-full V2.
 * @topic HotReload
 */
// Retained during PIE: ExistingValue and the old GetValue arity/shape; PartiallyHandled defers AddedValue.
// Replaced after next session: AddedValue=40 is live; GetValue uses ExistingValue+2.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadMultiplayerPIESuggestedGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadMultiplayerPIESuggestedLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	UPROPERTY()
	int AddedValue = 40;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 2;
	}
}
/** @end */
