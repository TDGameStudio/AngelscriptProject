// Theme: HotReload VersionPair After. Full reload replaces Value type.
// C++: AngelscriptHotReloadPropertyTests.cpp::PropertyTypeChangeReplacesFieldType ScriptV2
// Retained: UFullReloadTypeChangeTarget name; Value property name.
// Replaced: Value type FString; default "Reloaded"; UClass identity.
// Oracle After: FullReload handled; replacement class Value is not FIntProperty.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadTypeChangeTarget : UObject
{
	UPROPERTY()
	FString Value;

	default Value = "Reloaded";
}
