// Theme: HotReload VersionPair Before. Survivor plus UReloadRemovedTarget.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::ClassRemoved
// Retained: UReloadSurvivorTarget.
// Replaced after After.as: UReloadRemovedTarget is dropped.
// Oracle: FullReloadRequired; bWantsFullReload || bNeedsFullReload.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UReloadSurvivorTarget : UObject
{
}

UCLASS()
class UReloadRemovedTarget : UObject
{
}
