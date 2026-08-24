// Theme: HotReload VersionPair After. Game-instance subsystem soft-reload callable body.
// C++: AngelscriptHotReloadSubsystemTests.cpp::GameInstanceSubsystemSoftReloadUpdatesCallableBehavior ReloadV2Source
// Retained: UHotReloadGameInstanceSubsystemTarget UClass identity; existing subsystem instance.
// Replaced: GetValue body 13 -> 31.
// Oracle After: SoftReloadOnly handled; existing instance ExecuteSubsystemValue == 31.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadGameInstanceSubsystemTarget : UScriptGameInstanceSubsystem
{
	UFUNCTION()
	int GetValue()
	{
		return 31;
	}
}
