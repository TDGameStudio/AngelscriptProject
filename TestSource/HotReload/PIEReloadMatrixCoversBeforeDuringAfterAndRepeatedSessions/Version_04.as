// Theme: HotReload VersionPair Version_04. During-PIE required signature change.
// C++: AngelscriptHotReloadPIESessionTests.cpp::PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions ScriptV4DuringRequiredSignature
// Retained last-good (Version_03): UClass identity; GetValue() with no Extra; InvokeGetValue == 13.
// Replaced shape (rejected during PIE): GetValue(int Extra) returning ExistingValue + Extra.
// Oracle: SoftReloadOnly false; ErrorNeedFullReload; "Full Reload is required due to UPROPERTY() or UFUNCTION() changes".
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
	int GetValue(int Extra)
	{
		return ExistingValue + Extra;
	}
}
