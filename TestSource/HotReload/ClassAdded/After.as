// Theme: HotReload VersionPair After. Adds UNewReloadTarget beside the existing class.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::ClassAdded
// Retained: UExistingReloadTarget.
// Replaced: class set gains UNewReloadTarget. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UExistingReloadTarget : UObject
{
}

UCLASS()
class UNewReloadTarget : UObject
{
}
