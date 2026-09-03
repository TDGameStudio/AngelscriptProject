// Theme: HotReload VersionPair Before. After-PIE structural LevelScript V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::ReloadAfterPIEEndsAppliesToNextPIESession
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
