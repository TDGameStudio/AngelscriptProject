// Theme: HotReload VersionPair After. Adds ExtraValue beside Value.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::PropertyCountChange
// Retained: UReloadPropertyTarget and Value.
// Replaced: property count (ExtraValue added). Not SoftReload.
// FixtureIsolated.

UCLASS()
class UReloadPropertyTarget : UObject
{
	UPROPERTY()
	int Value;

	UPROPERTY()
	int ExtraValue;
}
