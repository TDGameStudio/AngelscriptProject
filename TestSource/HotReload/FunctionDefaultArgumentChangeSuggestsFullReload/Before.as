// Theme: HotReload VersionPair Before. SumWithDefault(int Value = 1).
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionDefaultArgumentChangeSuggestsFullReload
// Retained: UHotReloadChangeClassificationFunctionDefaultTarget, SumWithDefault body and type.
// Replaced after After.as: default argument 1 -> 2.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationFunctionDefaultTarget : UObject
{
	UFUNCTION()
	int SumWithDefault(int Value = 1)
	{
		return Value;
	}
}
