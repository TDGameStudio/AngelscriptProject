// Theme: HotReload VersionPair Before. Single UPROPERTY Value on UReloadPropertyTarget.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::PropertyCountChange
// Retained: UReloadPropertyTarget and Value field.
// Replaced after After.as: property count gains ExtraValue.
// Oracle: bWantsFullReload || bNeedsFullReload; FullReloadRequired or FullReloadSuggested.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UReloadPropertyTarget : UObject
{
	UPROPERTY()
	int Value;
}
