// Theme: HotReload VersionPair Before. Full reload replaces Value type.
// C++: AngelscriptHotReloadPropertyTests.cpp::PropertyTypeChangeReplacesFieldType ScriptV1
// Retained on old class: int Value default 8.
// Replaced in After: Value type int -> FString; default "Reloaded".
// Oracle Before: Value is FIntProperty.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadTypeChangeTarget : UObject
{
	UPROPERTY()
	int Value;

	default Value = 8;
}
