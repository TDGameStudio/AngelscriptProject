// Theme: HotReload VersionPair Before. World subsystem soft-reload callable body.
// C++: AngelscriptHotReloadSubsystemTests.cpp::WorldSubsystemSoftReloadUpdatesCallableBehavior ReloadV1Source
// Retained after reload: UClass identity; UScriptWorldSubsystem derivation; existing instance.
// Replaced in After: GetValue 41 -> 64.
// Oracle Before: ExecuteSubsystemValue == 41.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadWorldSubsystemTarget : UScriptWorldSubsystem
{
	UFUNCTION()
	int GetValue()
	{
		return 41;
	}
}
