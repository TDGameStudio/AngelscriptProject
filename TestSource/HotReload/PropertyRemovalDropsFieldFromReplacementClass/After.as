// Theme: HotReload VersionPair After. Full reload drops RemovedValue.
// C++: AngelscriptHotReloadPropertyTests.cpp::PropertyRemovalDropsFieldFromReplacementClass ReloadV2Source
// Retained: UFullReloadRemovalTarget name; Value field (new class).
// Replaced: UClass instance; RemovedValue absent; Value default 5.
// Oracle After: replacement class has no RemovedValue; old class still has it.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadRemovalTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 5;
}
