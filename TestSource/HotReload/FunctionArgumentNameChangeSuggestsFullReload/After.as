// Theme: HotReload VersionPair After. Echo argument renamed SecondValue.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionArgumentNameChangeSuggestsFullReload
// Retained: class, Echo, int parameter type and return.
// Replaced: FirstValue -> SecondValue. FullReloadSuggested.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionArgumentNameTarget : UObject
{
	/** Echo: exercises the echo behaviour. */
	UFUNCTION()
	int Echo(int SecondValue)
	{
		return SecondValue;
	}
}
