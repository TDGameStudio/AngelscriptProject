// Theme: HotReload VersionPair Before. Full reload drops RemovedValue.
// C++: AngelscriptHotReloadPropertyTests.cpp::PropertyRemovalDropsFieldFromReplacementClass ReloadV1Source
// Retained on old class after reload: RemovedValue layout (Value=3, RemovedValue=4).
// Replaced in After: UClass identity; RemovedValue dropped; Value default 3 -> 5.
// Oracle Before: RemovedValue present.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadRemovalTarget : UObject
{
	UPROPERTY()
	int Value;

	UPROPERTY()
	int RemovedValue;

	default Value = 3;
	default RemovedValue = 4;
}
