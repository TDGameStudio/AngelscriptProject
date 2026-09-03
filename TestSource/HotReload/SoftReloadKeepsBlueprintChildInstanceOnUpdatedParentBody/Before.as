// Theme: HotReload VersionPair Before. Soft-reload parent ExampleValue=30, GetValue returns 30.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody
// Retained: AHotReloadBlueprintChildSoftReloadParent UClass identity, Blueprint child class, live actor.
// Replaced after After.as: GetValue body 30 -> 42 (ExampleValue + 12). Layout unchanged.
// Oracle: InvokeGeneratedGetValue == 30 before SoftReloadOnly FullyHandled.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class AHotReloadBlueprintChildSoftReloadParent : AActor
{
	UPROPERTY()
	int ExampleValue = 30;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExampleValue;
	}
}
