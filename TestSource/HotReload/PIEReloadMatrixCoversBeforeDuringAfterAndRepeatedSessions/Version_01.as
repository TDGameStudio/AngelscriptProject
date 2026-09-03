// Theme: HotReload VersionPair Version_01. PIE reload matrix body V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions
// Retained across matrix steps: ExistingValue=10, GameMode / LevelScript names, SetReplicates(false).
// Replaced in Version_02: GetValue ExistingValue+1 -> ExistingValue+2. Later matrix versions are later TaskIds.
// FixtureIsolated. Before-PIE InvokeGetValue is 11.

UCLASS(Blueprintable)
class AHotReloadPIEMatrixGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEMatrixLevelScript : ALevelScriptActor
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
