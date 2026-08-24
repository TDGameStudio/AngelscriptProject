// Theme: HotReload VersionPair After. During-PIE required-full signature change.
// C++: AngelscriptHotReloadPIESessionTests.cpp::RequiredFullReloadDuringPIEKeepsOldCodeActive
// Retained live: Before GetValue() returns 31. This signature change must not become active during PIE.
// Replaced (deferred): GetValue(int Extra) returns 99 + Extra.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadPIEDuringRequiredGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringRequiredLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UFUNCTION()
	int GetValue(int Extra)
	{
		return 99 + Extra;
	}
}
