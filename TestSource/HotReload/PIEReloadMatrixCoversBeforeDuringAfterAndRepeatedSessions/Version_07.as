// Theme: HotReload VersionPair Version_07. After-second-PIE body reload.
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions ScriptV7AfterBody
// Retained: AddedValue=40; ExistingValue=10; GameMode class; SetReplicates(false).
// Replaced: GetValue body ExistingValue+AddedValue -> ExistingValue+AddedValue+1.
// Oracle: SoftReloadOnly FullyHandled; third PIE InvokeGetValue == 51.
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
		return ExistingValue + AddedValue + 1;
	}
}
