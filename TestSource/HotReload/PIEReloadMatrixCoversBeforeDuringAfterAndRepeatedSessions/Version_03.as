// Theme: HotReload VersionPair Version_03. During-PIE body reload.
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions ScriptV3DuringBody
// Retained: AHotReloadPIEMatrixGameMode; AHotReloadPIEMatrixLevelScript; SetReplicates(false); ExistingValue=10.
// Replaced vs Version_02: GetValue body ExistingValue+2 -> ExistingValue+3.
// Oracle: SoftReloadOnly FullyHandled; live InvokeGetValue == 13.
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

	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 3;
	}
}
