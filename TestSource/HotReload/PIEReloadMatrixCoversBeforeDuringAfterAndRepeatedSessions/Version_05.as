// Theme: HotReload VersionPair Version_05. During-PIE suggested property shape.
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions ScriptV5DuringSuggestedShape
// Retained during PIE: live LevelScriptActor; AddedValue not published on the PIE class.
// Replaced body (partially applied): GetValue ExistingValue+3 -> ExistingValue+4 (oracle 14).
// Oracle: SoftReloadOnly PartiallyHandled; "Performing a Soft Reload during PIE"; AddedValue deferred.
// FixtureIsolated. Load Version_01..Version_07 in recorded order.

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

	UPROPERTY()
	int AddedValue = 40;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 4;
	}
}
