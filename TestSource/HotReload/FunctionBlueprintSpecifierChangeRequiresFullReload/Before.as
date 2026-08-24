// Theme: HotReload VersionPair Before. GetValue BlueprintCallable.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionBlueprintSpecifierChangeRequiresFullReload
// Retained: UHotReloadChangeClassificationFunctionSpecifierTarget, GetValue returns 1.
// Replaced after After.as: BlueprintCallable -> BlueprintPure const.
// Oracle: FullReloadRequired, bWantsFullReload true, bNeedsFullReload true.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationFunctionSpecifierTarget : UObject
{
	UFUNCTION(BlueprintCallable)
	int GetValue()
	{
		return 1;
	}
}
