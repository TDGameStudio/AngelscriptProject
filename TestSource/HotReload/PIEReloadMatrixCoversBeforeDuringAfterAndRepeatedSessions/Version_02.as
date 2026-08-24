// Theme: HotReload VersionPair Version_02. PIE reload matrix body V2 (before-PIE reload).
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions
// Retained: ExistingValue=10, GameMode, LevelScript UClass identity, SetReplicates(false).
// Replaced: GetValue ExistingValue+1 -> ExistingValue+2 (12).
// FixtureIsolated.

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

	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 2;
	}
}
