// Theme: HotReload VersionPair After. default Value = 2.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::DefaultStatementChangeSuggestsFullReload
// Retained: class and Value field.
// Replaced: default statement 1 -> 2. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationDefaultStatementTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 2;
}
