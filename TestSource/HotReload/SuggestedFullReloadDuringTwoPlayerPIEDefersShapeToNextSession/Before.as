// Theme: HotReload VersionPair Before. Two-player PIE suggested-full V1.
// C++: AngelscriptHotReloadMultiplayerPIETests.cpp::SuggestedFullReloadDuringTwoPlayerPIEDefersShapeToNextSession
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
