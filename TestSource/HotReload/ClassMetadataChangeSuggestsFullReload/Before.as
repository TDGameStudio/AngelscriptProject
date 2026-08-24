// Theme: HotReload VersionPair Before. Class meta DisplayName Alpha.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::ClassMetadataChangeSuggestsFullReload
// Retained: UHotReloadChangeClassificationClassMetadataTarget empty UObject class.
// Replaced after After.as (TS-HR-0056, next part): DisplayName Alpha -> Beta.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS(meta=(DisplayName="Alpha"))
class UHotReloadChangeClassificationClassMetadataTarget : UObject
{
}
