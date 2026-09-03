// Theme: HotReload VersionPair Before. Echo(int FirstValue).
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionArgumentNameChangeSuggestsFullReload
// Retained: UHotReloadChangeClassificationFunctionArgumentNameTarget, Echo return type.
// Replaced after After.as: argument name FirstValue -> SecondValue.
// Oracle: FullReloadSuggested, bWantsFullReload true, bNeedsFullReload false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationFunctionArgumentNameTarget : UObject
{
	/** Echo: exercises the echo behaviour. */
	UFUNCTION()
	int Echo(int FirstValue)
	{
		return FirstValue;
	}
}
