// Theme: HotReload VersionPair After. After-PIE structural LevelScript V2.
// C++: AngelscriptHotReloadPIESessionTests.cpp::ReloadAfterPIEEndsAppliesToNextPIESession
// Retained: ExistingValue=12 and GameMode / LevelScript names.
// Replaced for the next PIE session: AddedValue=30; GetValue ExistingValue + AddedValue (42).
// FixtureIsolated.

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
