// Theme: HotReload VersionPair After. World subsystem soft-reload callable body.
// C++: AngelscriptHotReloadSubsystemTests.cpp::WorldSubsystemSoftReloadUpdatesCallableBehavior ReloadV2Source
// Retained: UHotReloadWorldSubsystemTarget UClass identity; existing subsystem instance.
// Replaced: GetValue body 41 -> 64.
// Oracle After: SoftReloadOnly handled; existing instance ExecuteSubsystemValue == 64.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadWorldSubsystemTarget : UScriptWorldSubsystem
{
	UFUNCTION()
	int GetValue()
	{
		return 64;
	}
}
