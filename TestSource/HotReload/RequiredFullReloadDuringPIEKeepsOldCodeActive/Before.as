// Theme: HotReload VersionPair Before. During-PIE required-full LevelScript V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::RequiredFullReloadDuringPIEKeepsOldCodeActive
// Retained while PIE is live: GetValue() with no args returning 31. Signature change in After is last-good, not applied.
// Replaced only after PIE ends / next full path: GetValue(int Extra).
// FixtureIsolated. C++ InvokeGetValue baseline is 31.

UCLASS(Blueprintable)
class AHotReloadPIEDuringRequiredGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringRequiredLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UFUNCTION()
	int GetValue()
	{
		return 31;
	}
}
