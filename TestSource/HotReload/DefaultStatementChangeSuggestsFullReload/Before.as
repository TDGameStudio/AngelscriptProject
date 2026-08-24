// Theme: HotReload VersionPair Before. default Value = 1.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DefaultStatementChangeSuggestsFullReload
// Retained: UHotReloadChangeClassificationDefaultStatementTarget and Value UPROPERTY.
// Replaced after After.as: default 1 -> 2.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationDefaultStatementTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 1;
}
