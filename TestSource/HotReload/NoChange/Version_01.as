// Theme: HotReload VersionPair Version_01. Unchanged module analyzed against itself.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::NoChange
// Retained: entire UReloadNoChangeTarget (Value default 10, GetValue).
// Replaced: none. C++ feeds ScriptV1 as both baseline and edit.
// Oracle: SoftReload; bWantsFullReload false; bNeedsFullReload false.
// FixtureIsolated.

UCLASS()
class UReloadNoChangeTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 10;

	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}
