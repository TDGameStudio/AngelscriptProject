// Theme: HotReload VersionPair Before. Script struct version chain.
// C++: AngelscriptHotReloadStructTests.cpp::StructFullReloadReplacesScriptStructAndKeepsVersionChain ReloadV1Source
// Retained on old struct after reload: Value=1 layout; Bonus absent; GetNewestVersion points at After.
// Replaced in After: UScriptStruct object; Bonus=2 field.
// Oracle Before: Value present; Bonus absent.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructPayload
{
	UPROPERTY()
	int Value = 1;
}
