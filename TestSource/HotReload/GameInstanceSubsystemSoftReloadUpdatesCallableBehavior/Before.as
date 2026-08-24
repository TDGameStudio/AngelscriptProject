// Theme: HotReload VersionPair Before. Game-instance subsystem soft-reload callable body.
// C++: AngelscriptHotReloadSubsystemTests.cpp::GameInstanceSubsystemSoftReloadUpdatesCallableBehavior ReloadV1Source
// Retained after reload: UClass identity; UScriptGameInstanceSubsystem derivation; existing instance.
// Replaced in After: GetValue 13 -> 31.
// Oracle Before: ExecuteSubsystemValue == 13.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadGameInstanceSubsystemTarget : UScriptGameInstanceSubsystem
{
	UFUNCTION()
	int GetValue()
	{
		return 13;
	}
}
