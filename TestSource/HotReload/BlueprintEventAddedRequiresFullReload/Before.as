// Theme: HotReload VersionPair Before. Only GetValue, no BlueprintEvent.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::BlueprintEventAddedRequiresFullReload
// Retained: UHotReloadChangeClassificationBlueprintEventAddedTarget and GetValue.
// Replaced after After.as: GetExtraValue BlueprintEvent is added.
// Oracle: FullReloadRequired, bWantsFullReload true, bNeedsFullReload true.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationBlueprintEventAddedTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
