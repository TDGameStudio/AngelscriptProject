// Theme: HotReload VersionPair After. GetValue BlueprintPure const.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionBlueprintSpecifierChangeRequiresFullReload
// Retained: class and GetValue return 1.
// Replaced: BlueprintCallable -> BlueprintPure; function becomes const. FullReloadRequired.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionSpecifierTarget : UObject
{
	UFUNCTION(BlueprintPure)
	int GetValue() const
	{
		return 1;
	}
}
