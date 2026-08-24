// Theme: HotReload VersionPair Before. Empty UCLASS with no class flags.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::ClassFlagChangeSuggestsFullReload
// Retained after reload: UHotReloadChangeClassificationClassFlagTarget name and UObject super.
// Replaced in After: UCLASS() -> UCLASS(Abstract). Oracle: FullReloadSuggested.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationClassFlagTarget : UObject
{
}
