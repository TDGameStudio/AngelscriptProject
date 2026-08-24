// Theme: HotReload VersionPair Before. Body-only GetValue returns 1.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::SoftReloadRequirement
// Retained: UReloadSoftRequirementTarget, GetValue signature, class layout.
// Replaced after After.as: GetValue body 1 -> 2.
// Oracle: SoftReload; bWantsFullReload false; bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UReloadSoftRequirementTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
