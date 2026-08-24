// Theme: HotReload VersionPair After. SumWithDefault default argument is 2.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionDefaultArgumentChangeSuggestsFullReload
// Retained: class, function name, return Value.
// Replaced: default 1 -> 2. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionDefaultTarget : UObject
{
	UFUNCTION()
	int SumWithDefault(int Value = 2)
	{
		return Value;
	}
}
