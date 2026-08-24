// Theme: HotReload VersionPair Version_06. After-PIE shape reload.
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions ScriptV6AfterShape
// Retained: AHotReloadPIEMatrixGameMode; ExistingValue=10; SetReplicates(false).
// Replaced: LevelScript UClass identity; AddedValue=40 now published; GetValue uses ExistingValue + AddedValue.
// Oracle: FullReload handled; second PIE AddedValue==40; InvokeGetValue == 50.
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

	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + AddedValue;
	}
}
